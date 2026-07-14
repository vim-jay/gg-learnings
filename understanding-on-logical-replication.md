# Understanding on Logical Replication in Postgres Database

## Publication (source/publisher side)

```sql
CREATE PUBLICATION my_pub FOR TABLE ORDERS, ORDER_ITEMS;
```

This just registers `metadata` - "these tables' changes are available for replication." It doesn't move any data by itself.

## Replication Slot

When a subscriber connects, PostgreSQL creates a logical replication slot on teh publisher. This slot:

- Marks a position in WAL Stream (an LSN) where decoding should start
- Prevents the publisher from recycling/deleting WAL segments that haven't been consumed yet - this is why replication slots can cause disk bloat if a subscriber falls behind or disconnects permanently

## Subscription (target/subscriber side)

On another Postgres instance:

```sql
CREATE SUBSCRIPTION my_sub
    CONNECTION 'host=... dbname=... user=... password=...'
    PUBLICATION my_pub;
```

This does two things:

- **Initial sync:** for each table in the publication, it does a ***COPY*** (table snapshot) to bring the subscriber's table up to the publisher's current state
- **Starts streaming:** after the snapshot, it begins consuming WAL changes from the point the snapshot was taken

## WAL Sender + logical decoding (the actual replication mechanism)

- A ***walsender*** process on the publisher reads the raw WAL stream
- It runs those raw WAL records through a ***logical decoding plugin*** - by default `pgoutput` - which reconstructs them into logical row-level changes: `INSERT row X, UPDATE row Y (old -> new), DELETE row Z`
- Onlychanages belonging to tables that are in the publication get decoded/sent - everything else in the WAL is filtered out
- This is exactly why `REPLICA IDENTITY` matters: for `UPDATE`/`DELETE`, `pgoutput` needs to tell teh subscriber which row to update/delete. With `DEFAULT`, it uses the primary key from the WAL record's old-tupel data; with `FULL`, it uses the entire old row (needed if there's no primary key, or if you want to match on full row content)

## Apply worker (subscriber side)

- A ***walreceiver***/***apply worker*** process on teh subscriber receives the decoded logical changes over standard libpq replication connection
- It replays them as regular `INSERT`/`UPDATE`/`DELETE` SQL operations against the subscriber's local tables
- After applying, it sends ***feedback*** back to the publisher acknowledging the LSN it has applied up to - this lets the publisher advance/reclaim WAL held by the slot

## Summary of flow

```txt
Publisher : transaction commits -> WAL written (Heap/Btree/Transaction records)`
            ↓
        walsender reads WAL -> pgoutput decodes only published tables' changes 
            ↓ (network, replication protocol)
Subscriber: apply worker receives logical changes -> applies a SQL to local tables
            ↓
        sends LSN feedback -> publisher avances replication slot
```

So a publication is just the ***filter*** ("what to replicate"), the ***replication slot + WAL*** is the ***durable queue***, and `pgoutput` ***+ apply worker*** are what actually turn raw WAL into replicated row changes on another server. This is also exactly the mechanism tools like Debezium, GoldenGate for Postgres, and other CDC systems hook into — they act as a custom subscriber consuming this same logical decoding stream instead of another Postgres instance.

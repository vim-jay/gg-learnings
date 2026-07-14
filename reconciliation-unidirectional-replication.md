# Reconciliation Scenarios in Unidirectional Replication

In unidirectional replication, GoldenGate calls these "collisions," not conflicts, and they arise from a fundamentally different cause than CDR: not two writers racing, but a timing overlap between the initial load and live change capture.

The core scenario: HANDLECOLLISIONS

Valid for: Replicat. Default: NOHANDLECOLLISIONS (off).

The problem it solves: When you first stand up replication, you typically do an initial bulk load (e.g., the COPY-based snapshot we saw CREATE SUBSCRIPTION do automatically for your native init_sub) while the source stays live and keeps changing. If the source is being modified during that load, Replicat's live change stream and the bulk load can overlap on the same rows — causing exactly the same symptom-shapes as CDR conflicts, but for a totally different reason:

Other unidirectional reconciliation scenarios (not solved by a single parameter)

| Collision | Cause | Reolution |
|-----|-----|-----|
| Duplicate-record(INSERT) |Row was already loaded by the initial bulk copy, then the same row's INSERT also arrives via the live change trail| The bulk-loaded static row is overwritten by the trail's change record |
| Missing-record (DELETE/UPDATE) | A change for a row arrives via the trail before the initial load has gotten to that row yet | The change is not discarded — for UPDATE, if a key column changed and the old-key row is missing, it converts to an INSERT; if the new-key row already exists, it deletes the old-key row and applies as an overlay | 

**Critical operational detail** the docs stress: this is meant to be **temporary**. You enable `HANDLECOLLISIONS` only for the duration of the initial-load overlap window, then explicitly disable it once the load-and-catchup phase is done. If it stays on permanently, Replicat would silently paper over genuinely abnormal errors going forward — any collision after steady-state replication has begun should be manually investigated, not auto-resolved, since it usually signals something actually wrong (e.g., a stale/misapplied checkpoint, or something writing to the target that shouldn't be).

Other unidirectional reconciliation scenarios (not solved by a single parameter)

- **Checkpoint-replay after an abend** — if Replicat crashes and restarts from an earlier checkpoint, it may re-apply operations it already committed, hitting the exact same INSERT-exists/DELETE-missing shape as above, purely from replay rather than true overlap. Same collision types, different root cause.
- **Something else writes to the "read-only" target** — the single-writer assumption in unidirectional replication is a process guarantee, not something GoldenGate enforces at the database level. If an app, script, or DBA touches postgres2 directly, Replicat's next change for that row will hit an unexpected-state error with no automatic resolution defined (this is really a governance problem, not a GoldenGate feature gap).
- **Silent drift** — DDL changes not replicated (schema mismatch), TRUNCATE not captured depending on config, or subtle type/precision differences between source and target — these don't throw apply errors at all, so nothing alerts you; they require periodic data validation (row counts, checksums, or a dedicated tool like Oracle GoldenGate Veridata) rather than any Extract/Replicat parameter.

## References

[Oracle Documentation - HANDLECOLLISIONS](https://docs.oracle.com/en/database/goldengate/core/26/reference/handlecollisions-nohandlecollisions.html)

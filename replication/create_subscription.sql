-- Run this on postgres2 (subscriber), against the "ecommerce" database.
-- Connects to postgres (publisher, on a different Docker network) via the
-- host machine's exposed port, simulating two servers on separate networks.
--
-- docker exec -i postgres2 psql -U postgres -d ecommerce -f - < create_subscription.sql

CREATE SUBSCRIPTION init_sub
    CONNECTION 'host=host.docker.internal port=5432 dbname=ecommerce user=postgres password=changeme'
    PUBLICATION init_pub;

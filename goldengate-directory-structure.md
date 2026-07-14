# Oracle GoldenGate 26ai (Microservices) — Directory Structure

Verified against the running `goldengate` container (image `container-registry.oracle.com/goldengate/goldengate-postgresql-free:latest`, deployment `Local`).

| Directory | Purpose |
|---|---|
| `/u01/ogg` | **OGG_HOME** — the installed software itself (read-only, versioned binaries/libraries). Nothing runtime/deployment-specific lives here. |
| `/u01/ogg/bin` | All executables — `adminsrvr`, `distsrvr`, `recvsrvr`, `pmsrvr`, `extract`, `replicat`, `adminclient`, `logdump`, `keygen`, etc. |
| `/u01/ogg/lib` | Shared libraries + the web UI static assets (`lib/htdocs/WebUI/...`) |
| `/u01/ogg/datadirect` | ODBC/database driver files GoldenGate uses to connect to non-Oracle sources/targets (e.g. PostgreSQL) |
| `/u02/Deployment` | **Deployment root** — everything specific to *this* deployment (`Local`), separate from the shared `/u01/ogg` install. This is the persistent, per-deployment state. |
| `/u02/Deployment/etc/conf/ogg` | Holds **GLOBALS** and would hold Extract/Replicat `.prm` parameter files (classic architecture's `dirprm` equivalent) |
| `/u02/Deployment/etc/ssl` | TLS/SSL certificates for the deployment's HTTPS endpoints |
| `/u02/Deployment/var/log` | Process logs — `adminsrvr.log`, `ServiceManager.log`, etc. |
| `/u02/Deployment/var/lock` | Lock files preventing duplicate process instances |
| `/u02/Deployment/var/lib/conf` | Internal runtime config state for services (e.g. `adminsrvr-config.dat`) — distinct from the human-edited `GLOBALS`/`.prm` files |
| `/u02/Deployment/var/lib/data` | **Trail files** (classic `dirdat` equivalent) — the actual captured/replicated change-data files Extract writes and Replicat reads |
| `/u02/Deployment/var/lib/archive` | Archived/aged-out trail files, once purged from active `data/` |
| `/u02/Deployment/var/lib/report` | Process run reports (classic `dirrpt` equivalent) — Extract/Replicat statistics and run history |
| `/u02/Deployment/var/lib/checkpt` | Checkpoint files (classic `dirchk` equivalent) — tracks each process's recovery position in its trail/source log |
| `/u02/Deployment/var/lib/credential` | **Credential store / wallet** — `ewallet.p12`/`ewallet.pf`, the encrypted store for `ALTER CREDENTIALSTORE`-added DB usernames/passwords |
| `/u02/Deployment/var/lib/wallet` | Encryption key wallet (separate from the credential wallet above — used for `ENCKEYS`/data encryption, not DB login credentials) |
| `/u02/Deployment/var/lib/def` | Data definition files (classic `dirdef` equivalent) — source/target table structure defs, used for heterogeneous replication where column types/layouts differ between source and target |
| `/u02/Deployment/var/lib/sql` | SQL scripts (e.g. auto-generated DDL replication scripts, if that feature is used) |
| `/u02/Deployment/var/lib/distpaths` | Distribution Server routing state — tracks trail-file delivery paths from Distribution Server to remote Receiver Servers |

Most `var/lib/*` subdirectories are empty until an Extract/Replicat is created — they populate once a capture/apply pipeline is configured.

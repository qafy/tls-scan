# TLS Scans

Scans the targets in `config/input.csv` (`IP[:port][,domain]`) with the goscanner (TLS + HTTP),
once per client hello in `config/client-hellos`.

- `scan/scan-tls.sh [input.csv]` runs a scan and writes results to `${BASEDIR}/YYYY/MM/YYYY-MM-DD-HHMM`
  (default `BASEDIR=/rpool/scans/tls-scans`, override via env var)
- `config/tls-scan.conf` holds the goscanner options
- `etc/` contains the systemd service and timer (weekly, Wed 07:00)

Local test run:

    BASEDIR=./results ./scan/scan-tls.sh

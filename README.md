# Forge SIEM — Helm Charts

Public Helm charts for Forge SIEM. Two charts are available:

| Chart | Description |
|---|---|
| [`agent/`](agent/) | DaemonSet — deploy the Forge SIEM agent on every node in a Kubernetes cluster |
| [`data-plane/`](data-plane/) | BYOC data plane — deploy ingest, detection, storage, and relay in your own cluster |

## Add the repo

```bash
helm repo add forge-siem https://platformforgegroup.github.io/forge-siem-charts
helm repo update
```

---

## `agent` — Kubernetes DaemonSet

Deploys the Forge SIEM agent on every node. Collects logs, monitors file integrity, tracks process activity, and ships events over mTLS to the Forge ingest endpoint.

**Prerequisites:** An enrollment token from your Forge dashboard (Agents → Enrollment Tokens → New Token).

```bash
helm install forge-agent forge-siem/forge-siem-agent \
  --namespace forge-siem-agent --create-namespace \
  --set enrollment.token=<your-token> \
  --set enrollment.groups[0]=my-cluster
```

Agents appear in your dashboard at `app.platformforgegroup.com` within 30 seconds of the DaemonSet becoming ready.

### Key values

| Key | Default | Description |
|---|---|---|
| `enrollment.token` | `""` | Enrollment token from the Forge dashboard |
| `enrollment.apiURL` | `https://api.platformforgegroup.com` | Forge API endpoint |
| `enrollment.ingestURL` | `ingest.platformforgegroup.com:1514` | Forge ingest endpoint (mTLS TCP) |
| `enrollment.groups` | `[]` | Group tags — used for routing rules and filtering in the UI |
| `image.tag` | `latest` | Pin to a specific release in production |
| `tolerations` | `- operator: Exists` | Runs on all nodes including control-plane by default |
| `hostPaths.containerSocket.enabled` | `false` | Enable to attach container runtime metadata to events |
| `rbac.create` | `true` | Creates ServiceAccount + ClusterRole for pod metadata reads |

See [`agent/values.yaml`](agent/values.yaml) for all options.

---

## `data-plane` — BYOC data plane

Deploys the full Forge SIEM data plane into your own Kubernetes cluster. Your raw events stay in your environment — the Forge-hosted dashboard at `app.platformforgegroup.com` queries your data plane via the relay service.

**Prerequisites:**
- Kubernetes cluster
- PostgreSQL, Redis, and ClickHouse (customer-provided)
- A relay API key from the Forge admin portal (Tenants → \[your tenant\] → Data Plane → Connect)

```bash
helm install forge-data-plane forge-siem/forge-siem-byoc \
  --namespace forge-byoc --create-namespace \
  --set forge.tenantID=<your-tenant-id> \
  --set forge.relayAPIKey=<fdp_key-from-portal> \
  --set forge.relayPublicURL=https://relay.yourdomain.com \
  --set dependencies.postgres.dsn="postgres://user:pass@host:5432/forge_siem?sslmode=require" \
  --set dependencies.redis.addr="redis-host:6379" \
  --set dependencies.clickhouse.addr="ch-host:9000"
```

After install, click **Ping** in the admin portal to confirm the relay is reachable. Your analysts will see data in the Forge dashboard within minutes of agents enrolling.

### Services deployed

| Service | Port | Role |
|---|---|---|
| `forge-ingest` | 1514 | Receives agent events over mTLS |
| `forge-decoder` | — | Parses and normalises events |
| `forge-raw-archiver` | — | Archives raw events to ClickHouse (+ S3 optional) |
| `forge-rules-engine` | — | Evaluates detection rules, fires alerts |
| `forge-alert-indexer` | — | Writes alerts to ClickHouse and PostgreSQL |
| `forge-relay` | 8443 | Bridges Forge dashboard queries to your local data |

See [`data-plane/values.yaml`](data-plane/values.yaml) for all options.

---

## Security

- The relay authenticates every inbound request with a `Bearer fdp_*` token. Rotate it any time in the admin portal.
- All agent→ingest traffic uses mTLS (TLS 1.3).
- No raw log content is ever transmitted to Forge infrastructure.

## License

Charts are provided under the [Forge SIEM Terms of Service](https://platformforgegroup.com/terms).
The service images referenced by these charts are proprietary — a valid Forge SIEM subscription is required to use them.

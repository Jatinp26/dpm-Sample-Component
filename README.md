# Sample DPM Component
A DPM component that adds `dpm canton-scaffold` to Scaffold project starters.

## Requirements
- DPM 1.0.14+ (bundled with SDK 3.5+)
- Docker + Docker Compose (for `canton-dapp` and `canton-validator-app`)

## Install (as a consumer)

Add to your `daml.yaml`. Do **not** include `sdk-version` when using `components:` as DPM does not allow both simultaneously.

```yaml
name: my-project
source: daml
version: 0.0.1
dependencies:
  - daml-prim
  - daml-stdlib

components:
  - oci://ghcr.io/.../components/canton-scaffold:0.1.0
```

```bash
dpm install package
```

After install, make the script executable (required on macOS/Linux):

```bash
chmod +x ~/.dpm/cache/components/.../canton-scaffold/0.1.0/bin/canton-scaffold.sh
```

This installs the component and makes `dpm canton-scaffold` available.

## Usage

```bash
# List available templates
dpm canton-scaffold list

# e.g. Scaffold a CIP-0056 token app
dpm canton-scaffold canton-token-app my-token
```

## Publish (for component maintainers)

Before publishing, ensure the script is executable, this permission must be set in your working directory before the OCI push, as it does not survive the archive without it:

### component.yaml schema

```yaml
# $schema: https://raw.githubusercontent.com/digital-asset/dpm/refs/heads/main/schema/component.v1.schema.json
apiVersion: digitalasset.com/v1
kind: Component
spec:
  commands:
    - path: bin/canton-scaffold.sh
      name: canton-scaffold
      desc: "Scaffold a Canton Network application project"
```

### Local registry testing

```bash
# Start a local OCI registry
docker run -d -p 5001:5000 --name oci-registry registry:2

# Verify it's running
curl http://localhost:5001/v2/

# Dry run to validate manifest
DPM_SDK_VERSION=3.5.2-snapshot.20260514.586.0.v15742f1c \
  dpm publish component oci://localhost:5001/canton-scaffold:0.1.0 \
    --platform generic="." \
    --dry-run

# Publish
DPM_SDK_VERSION=3.5.2-snapshot.20260514.586.0.v15742f1c \
  dpm publish component oci://localhost:5001/canton-scaffold:0.1.0 \
    --platform generic="." \
    --insecure
```

> **Note:** `--insecure` must be passed as a CLI flag to `dpm publish component`. 

### Production registry

```bash
dpm publish component oci://ghcr.io/.../components/canton-scaffold:0.1.0 \
    --platform generic="."
```

## Known issues and gotchas

| Issue | Detail |
|---|---|
| `sdk-version` + `components:` conflict | DPM does not allow both in `daml.yaml`. Remove `sdk-version` when using `components:`. |
| `--insecure` not in `dpm install package` | The flag doesn't exist there. Use `insecure: true` in `dpm-config.yaml` instead for local registry consumption. |
| Script permission denied after install | Run `chmod +x ~/.dpm/cache/components/.../bin/canton-scaffold.sh` after `dpm install package`. |
| Consumer side external registry (3.4.x) | `override-components` registry key is silently ignored on 3.4.x. Full consume loop requires DPM 3.5+. Confirmed on 3.4.11. |

## Local Development

```bash
./bin/canton-scaffold.sh list
./bin/canton-scaffold.sh info canton-dapp
./bin/canton-scaffold.sh canton-dapp test-project
```

## Resources

- Canton Network developer docs: https://docs.canton.network
- CIP-0056 Token Standard: https://github.com/canton-foundation/cips/blob/main/cip-0056/cip-0056.md
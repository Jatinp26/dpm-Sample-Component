# dpm-tools

Example [dpm](https://github.com/digital-asset/dpm) components — CLI extensions
that `dpm` discovers and runs as subcommands. Use them as-is, or as a starting
point for building your own dpm extension.

| Tool | What it does |
|------|--------------|
| [`canton-scaffold`](examples/canton-scaffold/) | Example canton scaffolding extension |
| [`rst-to-mdx`](examples/rst-to-mdx/) | Convert reStructuredText into Mintlify-compatible MDX |
| [`mdx-validate`](examples/mdx-validate/) | Validate Mintlify MDX documentation files |

Each examples's README covers building it, running it through `dpm`, and publishing
it as an OCI component.

## Prerequisites: install dpm

These are extensions to the `dpm` CLI, so you need `dpm` on your `PATH` to build
or run them. The easiest way is to pull a prebuilt binary straight from a
[dpm GitHub release](https://github.com/digital-asset/dpm/releases).

Release assets are named `dpm-<version>-<os>-<arch>.tar.gz`, where `os` is one of
`darwin` / `linux` / `windows` and `arch` is `amd64` or `arm64`. Grab the archive
for your platform, unpack it (goreleaser strips the directory, so the tarball
holds a bare `dpm` binary), and put it on your `PATH`.

With the GitHub CLI (resolves the latest release for you):

```sh
# macOS Apple silicon — swap the pattern for your os/arch
gh release download --repo digital-asset/dpm --pattern 'dpm-*-darwin-arm64.tar.gz'
tar -xzf dpm-*-darwin-arm64.tar.gz
sudo mv dpm /usr/local/bin/            # or anywhere on your PATH
dpm --version
```

Or download a specific version directly, no `gh` required:

```sh
VERSION=1.0.21                         # check the releases page for the latest
curl -fSL -o dpm.tar.gz \
  "https://github.com/digital-asset/dpm/releases/download/${VERSION}/dpm-${VERSION}-darwin-arm64.tar.gz"
tar -xzf dpm.tar.gz && sudo mv dpm /usr/local/bin/
```

Windows ships a standalone `dpm-<version>-windows-amd64.exe` on the same release.
Each release also publishes a `dpm-<version>-checksums.txt` for verification.

Once `dpm` is installed, follow the tool's README to build and register the
component for local development.

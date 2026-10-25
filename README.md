# SpanDock releases

Downloads for **SpanDock**, a local gateway that collects OpenTelemetry traces, logs, and metrics from AI coding tools (Claude Code, Codex, Gemini CLI). It shows them on local dashboards, keeps them in an embedded DuckDB database, and forwards them to Langfuse, Grafana Cloud, New Relic, or any OTLP backend.

SpanDock is **one app**. On first launch it asks whether this computer is a **server** (for yourself or a team) or a **client** (connects to a server), and remembers the answer. A server is activated by signing in at spandock.com; a client joins a server with the pairing code the server gives it. Installed copies check the [latest release](https://github.com/SpanDock/spandock-releases/releases/latest) and update themselves.

## Install

**macOS (Homebrew, recommended; no "Open Anyway" prompt):**
```bash
brew install --cask spandock/spandock/spandock
```

**Linux, or a server VM:**
```bash
brew install spandock/spandock/spandock
spandock -role=server -accept-eula -open=false -menubar=false   # first start: prints a link and code; approve it by signing in at spandock.com
brew services start spandock
```

Without Homebrew, download the file for your system from the latest release:

| System | File |
| --- | --- |
| macOS, Apple Silicon | `SpanDock-<version>-macos-arm64.dmg` |
| macOS, Intel | `SpanDock-<version>-macos-amd64.dmg` |
| Linux x86-64 / ARM64 | `spandock-linux-amd64.tar.gz` / `spandock-linux-arm64.tar.gz` |
| Windows x86-64 | `spandock-windows-amd64.zip` |

On macOS, drag the app to Applications. Then run `xattr -dr com.apple.quarantine /Applications/SpanDock.app` once, because SpanDock isn't notarized yet.

Every file is listed with its SHA-256 in `checksums.txt`:
```bash
shasum -a 256 -c checksums.txt --ignore-missing   # macOS
sha256sum -c checksums.txt --ignore-missing       # Linux
```

## Deploy a server in the cloud

A server needs no inbound port and no public address: it only connects out. Each button opens the provider's console with SpanDock's template filled in; check the size and region, create it, then approve the link the server prints (its serial console, or `journalctl -u spandock`).

| Provider | One click |
| --- | --- |
| AWS | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/quickcreate?templateURL=https%3A%2F%2Fspandock-cloud-setup.s3.us-east-1.amazonaws.com%2Fdeploy%2Fspandock-aws.yaml&stackName=spandock) |
| Microsoft Azure | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fwww.spandock.com%2Fdeploy%2Fazure%2Fazuredeploy.json) |
| Google Cloud | [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FSpanDock%2Fspandock-deploy&cloudshell_workspace=terraform%2Fgcp) |
| Oracle Cloud (Always Free) | [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https%3A%2F%2Fwww.spandock.com%2Fdeploy%2Fspandock-oracle-stack.zip) |
| Render | [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https%3A%2F%2Fgithub.com%2Fspandock%2Fspandock-deploy) |
| Docker, Fly.io, Railway | The image `ghcr.io/spandock/spandock`: [Containers](docs/DEPLOY.md#containers) |
| Kubernetes | The Helm chart `oci://ghcr.io/spandock/charts/spandock`: [Kubernetes](docs/DEPLOY.md#kubernetes) |
| Hetzner, DigitalOcean | One command with their CLI: [Hetzner and DigitalOcean](docs/DEPLOY.md#hetzner-and-digitalocean) |
| Any other provider | Paste [cloud-init.yaml](https://www.spandock.com/deploy/cloud-init.yaml) as the VM's user data |

The full guide, from sizes to activation, pairing, the public endpoint, updates and removal: **[docs/DEPLOY.md](docs/DEPLOY.md)**. The templates, Terraform and Ansible kits are in [SpanDock/spandock-deploy](https://github.com/SpanDock/spandock-deploy).

## Other files

- `SpanDock-macos-<arch>.zip`, `spandock-<os>-<arch>.tar.gz`, `spandock-windows-<arch>.zip`: what the built-in updater downloads.
- `SpanDock-Server-…`, `SpanDock-Client-…`, `spandock-server-…`, `spandock-client-…`: the same build, under the names of the apps from before v0.6. Those apps keep updating from these files and stay in their mode.
- [`cloud-setup/`](cloud-setup): the setup files SpanDock's **Settings → Scaling → Object storage** opens when you choose **Set up in Azure** or **Set up in Google Cloud** (a bucket for settings and backups).

## More

- Homebrew tap: [SpanDock/homebrew-spandock](https://github.com/SpanDock/homebrew-spandock)
- Deploy kits: [SpanDock/spandock-deploy](https://github.com/SpanDock/spandock-deploy)
- After installing, the dashboard opens at http://127.0.0.1:8787. Pair clients from the server's **Clients** page, and connect your AI tools under **Integrations**.

## License

SpanDock is proprietary software, free to use under the [End User License Agreement](https://www.spandock.com/legal/eula), with [paid plans](https://www.spandock.com/pricing) for larger teams. It is not open source. See [LICENSE](LICENSE). The open-source components it includes are listed in `THIRD_PARTY_NOTICES.txt` in each release.

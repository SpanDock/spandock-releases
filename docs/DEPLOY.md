# Deploy a SpanDock server in the cloud

This guide puts a SpanDock server on a cloud VM, a container platform or Kubernetes, activates it, and pairs your first computer with it.

A SpanDock server needs **no inbound port and no public address**. It only connects out: paired computers reach it over its own encrypted tunnel. Every template below opens nothing to the internet. You only open a port if you later want a [public endpoint](#public-endpoint-for-cloud-tools) for cloud tools.

- [What a server needs](#what-a-server-needs)
- [One-click deploy](#one-click-deploy)
- [Other providers](#other-providers)
- [Containers](#containers)
- [Kubernetes](#kubernetes)
- [Activate the server](#activate-the-server)
- [Open the dashboard](#open-the-dashboard)
- [Pair the first computer](#pair-the-first-computer)
- [Add a satellite](#add-a-satellite)
- [Public endpoint for cloud tools](#public-endpoint-for-cloud-tools)
- [Networks that inspect HTTPS](#networks-that-inspect-https)
- [Updates and rollback](#updates-and-rollback)
- [Backups](#backups)
- [Remove a server](#remove-a-server)

## What a server needs

| | |
| --- | --- |
| **Operating system** | Linux with glibc 2.38 or later and systemd: Ubuntu 24.04 or later, Debian 13, RHEL 10, Fedora 39 or later. Or any platform that runs the container image. |
| **Processor** | 64-bit x86 or ARM (both are built for every release) |
| **Size** | 2 vCPU, 4 GB of memory and 30 GB of disk suit up to about 50 developers. For larger teams, use the [hardware calculator](https://www.spandock.com/requirements). |
| **Network** | Outbound HTTPS only. No inbound port. |
| **Account** | A spandock.com account. A Personal license is free, and a new server's first activation starts a 30-day trial of the paid features. |

What it uses in practice:

- **Memory:** an idle server uses about 90 MB. Under load most memory goes to its database, which gets an eighth of the machine's memory (between 512 MB and 2 GB).
- **Disk:** about 1.5 KB per span, so a million spans take about 1.5 GB. History is kept for 30 days and 2 GB by default; you can change both in the server's settings. The program itself is about 100 MB, and an update keeps the previous version until the new one is healthy.

A server with Docker or Kubernetes stores everything in one volume at `/data`. Give it 20 GB or more.

## One-click deploy

Each button opens the provider's own console with SpanDock's template filled in. Check the size and region, create it, then [activate the server](#activate-the-server).

| Provider | One click |
| --- | --- |
| AWS | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/quickcreate?templateURL=https%3A%2F%2Fspandock-cloud-setup.s3.us-east-1.amazonaws.com%2Fdeploy%2Fspandock-aws.yaml&stackName=spandock) |
| Microsoft Azure | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fwww.spandock.com%2Fdeploy%2Fazure%2Fazuredeploy.json) |
| Google Cloud | [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FSpanDock%2Fspandock-deploy&cloudshell_workspace=terraform%2Fgcp) |
| Oracle Cloud (Always Free) | [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https%3A%2F%2Fwww.spandock.com%2Fdeploy%2Fspandock-oracle-stack.zip) |
| Render | [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https%3A%2F%2Fgithub.com%2Fspandock%2Fspandock-deploy) |

The templates and kits are open source in [SpanDock/spandock-deploy](https://github.com/SpanDock/spandock-deploy). Every VM kit installs the same thing: a `spandock` service account, the latest release checked against its published checksums, and a systemd service that restarts on failure.

### AWS

1. Sign in to the AWS console and press **Launch Stack**.
2. Pick the region at the top right. Keep the stack name `spandock` or choose your own.
3. Check the parameters: the instance type (`t3.medium` by default; set `Architecture` to `arm64` for a `t4g` instance), the disk size (30 GB) and, for a satellite, the join code. SSH stays closed unless you fill in a key pair and an address range.
4. Tick the acknowledgement and choose **Create stack**.

It creates an EC2 instance with Ubuntu 24.04, an encrypted gp3 disk, IMDSv2 and a security group with no inbound rule, in the account's default VPC. To read the activation link: EC2 → the instance → **Actions → Monitor and troubleshoot → Get system log**.

### Microsoft Azure

1. Press **Deploy to Azure** and sign in.
2. Choose a subscription and a new resource group (it makes removing the server one step).
3. Pick the region and size (`Standard_B2s` by default) and paste an SSH public key. Azure requires one; SSH stays closed.
4. Choose **Review + create**, then **Create**.

It creates a VM with Ubuntu 24.04, Trusted Launch and boot diagnostics, in its own network with a security group that has no inbound rule. To read the activation link: the VM → **Help → Serial console**, or **Boot diagnostics → Serial log**.

### Google Cloud

1. Press **Open in Cloud Shell** and confirm. Cloud Shell opens with the Terraform kit.
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and set your project ID, and optionally the region, machine type (`e2-medium` by default) and disk.
3. Run:

   ```bash
   terraform init && terraform apply
   ```

It creates a Compute Engine VM with Ubuntu 24.04, Shielded VM and no firewall rule. To read the activation link: the VM → **Logs → Serial port 1 (console)**, or run the command in Terraform's `activation` output.

### Oracle Cloud

1. Press **Deploy to Oracle Cloud** and sign in. Resource Manager opens with the stack.
2. Accept the terms, choose the compartment, then **Next**.
3. Check the shape: the Always Free Ampere shape with 2 OCPUs, 12 GB of memory and a 50 GB disk by default.
4. Choose **Create**, with **Run apply** ticked.

It creates the VM in its own network with no inbound rule. To read the activation link: the instance → **Console connection**, or **Resources → Console history**.

### Render

1. Press **Deploy to Render** and sign in.
2. Render reads the blueprint: a background worker running the image `ghcr.io/spandock/spandock`, with a 20 GB disk at `/data` and no public HTTP service. Workers with a disk need a paid plan.
3. Choose **Apply**.

The activation link is in the worker's **Logs**.

## Other providers

### Fly.io

```bash
fly launch --from https://github.com/spandock/spandock-deploy --copy-config --no-deploy
fly deploy
fly logs        # the activation link
```

`fly launch` asks for the app's name and region. The kit runs the image on a Machine (2 shared CPUs, 4 GB) with a 20 GB volume at `/data` and no public service.

### Railway

Create a service from the Docker image `ghcr.io/spandock/spandock:latest`:

1. Add a volume mounted at `/data`.
2. Add the variable `SPANDOCK_ACCEPT_EULA=1` (it accepts the [End User License Agreement](https://www.spandock.com/legal/eula)).
3. Don't add a public domain or networking: the server needs none.
4. Deploy. The activation link is in the service's **Deploy logs**.

### Hetzner and DigitalOcean

They have no deploy button, so it's one command with their own CLI:

```bash
curl -fsSL https://www.spandock.com/deploy/cloud-init.yaml -o spandock-cloud-init.yaml
# Hetzner Cloud (hcloud): CPX21 in Falkenstein, or CAX11 for ARM
hcloud server create --name spandock --type cpx21 --image ubuntu-24.04 --location fsn1 --user-data-from-file spandock-cloud-init.yaml
# DigitalOcean (doctl): 2 vCPU and 4 GB in Frankfurt
doctl compute droplet create spandock --size s-2vcpu-4gb --image ubuntu-24-04-x64 --region fra1 --user-data-file spandock-cloud-init.yaml --wait
```

To read the activation link: Hetzner: `hcloud server request-console spandock`; DigitalOcean: the Droplet's **Recovery Console**. Or over SSH, `journalctl -u spandock -f`.

### Any other provider

When you create a VM (Ubuntu 24.04 or later, or Debian 13), paste [cloud-init.yaml](https://www.spandock.com/deploy/cloud-init.yaml) as its **user data**. This works on Akamai (Linode), Vultr, Scaleway, OVHcloud and most others. For a satellite, put the join code in the file's `SPANDOCK_JOIN_CODE=''`.

### A Linux machine you already have

```bash
curl -fsSL https://www.spandock.com/deploy/install-server.sh | sudo bash
```

It installs SpanDock as the `spandock` systemd service under its own account and prints the activation link. Running it again upgrades the binary and keeps the data and settings.

- **Where things are:** the program is `/var/lib/spandock/bin/spandock`, owned by the service account so SpanDock can update itself. Its data is in `/var/lib/spandock`, its first-start settings in `/etc/spandock/server.env`.
- **Commands:** the script installs a `spandock` command that runs as the service account with the service's settings: `spandock license status`, `spandock admin pair`, `sudo spandock onboard` (set it up by answering questions). Don't start a second `spandock -role=server` beside the service: they would compete for the same ports.
- **The service:** `systemctl status spandock`, `journalctl -u spandock -f`.
- **Options:** `SPANDOCK_VERSION=v0.66.0` installs that version instead of the latest; `SPANDOCK_JOIN_CODE='…'` makes a satellite. Put them after `sudo`: `curl … | sudo SPANDOCK_VERSION=v0.66.0 bash`.

### Terraform and Ansible

[SpanDock/spandock-deploy](https://github.com/SpanDock/spandock-deploy) also has Terraform modules for [AWS](https://github.com/SpanDock/spandock-deploy/tree/main/terraform/aws) and [Google Cloud](https://github.com/SpanDock/spandock-deploy/tree/main/terraform/gcp), and an [Ansible role](https://github.com/SpanDock/spandock-deploy/tree/main/ansible) for hubs and satellites on hosts you manage. Each has its own README.

## Containers

Every release is also a container image, for `linux/amd64` and `linux/arm64`: **`ghcr.io/spandock/spandock`** (`:latest`, or a version such as `:0.66.0`).

```bash
docker run -d --name spandock --restart unless-stopped -v spandock-data:/data \
  -e SPANDOCK_ACCEPT_EULA=1 ghcr.io/spandock/spandock
docker logs spandock                           # the activation link: open it, sign in, approve
docker exec spandock spandock admin pair my-laptop   # a pairing code for your first computer
```

With Docker Compose, save this as `docker-compose.yml` (it's also [in the kit](https://github.com/SpanDock/spandock-deploy/blob/main/docker-compose.yml)), then `docker compose up -d` and `docker compose logs spandock`:

```yaml
services:
  spandock:
    image: ghcr.io/spandock/spandock:latest
    restart: unless-stopped
    environment:
      SPANDOCK_ACCEPT_EULA: "1"        # accepts https://www.spandock.com/legal/eula
      # SPANDOCK_JOIN_CODE: ""         # only for a satellite, on its first start
    volumes:
      - spandock-data:/data
volumes:
  spandock-data:
```

- **No port to publish.** Computers reach the server over its tunnel. The dashboard listens on the container's own loopback: manage the server from a paired computer (**Open server dashboard**), or with `docker exec spandock spandock admin …`.
- **`/data` holds everything:** settings, the database and the server's secrets (in a file only its user can read, since a container has no keychain). Keep it on a volume and back it up, or use [Backups](#backups).
- **Updates come as a new image.** SpanDock never replaces its own program inside a container. See [Updates and rollback](#updates-and-rollback).
- It runs as a non-root user (65532) on a distroless Debian 13 base, with no shell.

On a container platform (Render, Fly.io, Railway), run it as a **worker** with no public HTTP service and a persistent volume at `/data`.

## Kubernetes

A Helm chart comes with every release, beside the image: **`oci://ghcr.io/spandock/charts/spandock`**. The chart's version is SpanDock's.

```bash
helm install spandock oci://ghcr.io/spandock/charts/spandock --version 0.66.0 \
  --namespace spandock --create-namespace --set eula.accept=true
kubectl logs -n spandock statefulset/spandock | grep -i activat       # the activation link
kubectl port-forward -n spandock statefulset/spandock 8787            # then http://127.0.0.1:8787
kubectl exec -n spandock statefulset/spandock -- spandock admin pair my-laptop
```

- **One server per release:** a StatefulSet with a volume for `/data` (`persistence.size`, 20 GiB by default, or `persistence.existingClaim`).
- **No port is needed.** For the [public endpoint](#public-endpoint-for-cloud-tools), set `publicEndpoint.enabled=true`: SpanDock listens on `publicEndpoint.port` (8443) behind a Service (`LoadBalancer` on 443 by default), with its own certificate (`publicEndpoint.tls=acme`) or behind your ingress (`proxy`).
- **A satellite:** install the chart again with `joinCodeSecret` naming a Secret whose key `code` holds the hub's join code. Never put the code in values.
- **Provider keys from Secrets:** pass them as environment variables (`extraEnv` with `secretKeyRef`), and enter `env:NAME` as the key under **Settings → AI models**. SpanDock reads it on each use.
- **Air-gapped (Enterprise):** `licenseSecret` names a Secret whose key `license` holds the offline license file.
- It runs as the non-root user 65532 with a read-only root filesystem, no privileges and every capability dropped. Requests 100m CPU and 256 MiB of memory, limit 2 GiB; change them under `resources`.

## Activate the server

Every server needs a spandock.com account, and a new server waits for one approval before it starts. There is no key to paste.

1. A few minutes after the machine boots, the server prints a **link** and a **code**. Read them where your provider shows the console, or:

   | Where it runs | Command |
   | --- | --- |
   | A VM (over SSH) | `journalctl -u spandock -f` |
   | Docker | `docker logs spandock` |
   | Docker Compose | `docker compose logs spandock` |
   | Kubernetes | `kubectl logs -n spandock statefulset/spandock` |
   | Fly.io | `fly logs` |
   | Render, Railway | the service's logs in their dashboard |

2. Open the link on any device and sign in to spandock.com. A free Personal license is created if you have none.
3. Check that the code on the page matches the code the server printed, then approve.

The server stores its license and starts. Restarts and updates never ask again. `spandock license status` shows the license. An air-gapped Enterprise server starts with `-license-file FILE` instead.

A satellite never activates: it follows its hub's license.

## Open the dashboard

The dashboard listens only on the server's own `127.0.0.1:8787`. Reach it one of these ways:

- **From a paired computer** (the easiest): in SpanDock on that computer, paste a management token under **Settings → Server management**, then choose **Open server dashboard**. Create the token on the server with `spandock admin management-token my-laptop`.
- **Over SSH:** `ssh -L 8787:127.0.0.1:8787 <server>`, then open http://127.0.0.1:8787 on your computer.
- **Kubernetes:** `kubectl port-forward` as above.

## Pair the first computer

1. **On the server,** create a single-use pairing code:

   ```bash
   spandock admin pair -owner maya@example.com my-laptop
   ```

   Or in the dashboard: **Clients → Add client**. The first computer to use the code becomes that client.
2. **On the computer,** [install SpanDock](https://github.com/SpanDock/spandock-releases#install), choose **client** when it asks, and paste the code under **Settings → Server connection**. It restarts and connects.
3. **Connect your AI tools** under **Integrations**: select Claude Code, Codex, Gemini CLI or another tool, choose **Configure**, then restart the tool.

To vet new computers first, turn on **Require approval for new clients** in the server's settings; `spandock admin clients` lists them and `spandock admin approve CLIENT-ID` approves one.

## Add a satellite

More servers can join a hub as **satellites**, for regions, redundancy or a public edge. Satellites need Premium or Enterprise.

1. On the hub: **Settings → Scaling → Add server**, and copy the join code. It works once, for 30 minutes. Treat it like a password.
2. Deploy the new server with the code:
   - the one-click forms' join code field;
   - `SPANDOCK_JOIN_CODE` for the install script, cloud-init or a container;
   - `join_code` for Terraform, `spandock_join_code` for Ansible, `joinCodeSecret` for Helm.

The satellite joins by itself and follows the hub's settings, license and version.

## Public endpoint for cloud tools

Cloud services such as Cursor, CI runners and SaaS automations call models from their own servers, so they can't pair a SpanDock client. Give them a **public endpoint** (`https://<server>.<your domain>`) and a **service key** (Premium and Enterprise). Their calls go through the model proxy with your routing, budgets and recording; nothing else is reachable there.

The usual setup is a small VM joined as a satellite (an "edge"), so the hub stays private. **Settings → Public endpoint** walks you through it:

1. **Add an edge satellite.** Open TCP 443 in the VM's firewall, and give it the hub's join code and the public listener on its first start:

   ```bash
   curl -fsSL https://www.spandock.com/deploy/install-server.sh | \
     sudo SPANDOCK_JOIN_CODE='…' SPANDOCK_PUBLIC_LISTEN=0.0.0.0:443 SPANDOCK_PUBLIC_NAME=edge bash
   ```

   Other first-start variables: `SPANDOCK_PUBLIC_TLS` (`acme`, `files` or `proxy`), `SPANDOCK_ACME_EMAIL`, and on a hub `SPANDOCK_PUBLIC_DOMAIN`.
2. **Domain and HTTPS.** Enter your domain. Create the DNS record SpanDock shows (an `A` record to the server's public IP, `AAAA` for IPv6), press **Check DNS**, then **Issue certificate**. SpanDock gets a Let's Encrypt certificate on port 443 and renews it by itself. Your own certificate files, or a TLS proxy in front, work too.
3. **Create a service key.** Name it, choose the person it spends as, the allowed paths (OpenAI-compatible, Anthropic, OpenTelemetry, MCP) and optionally IP ranges, an expiry and a rate. The key is shown once.
4. **Copy the setup** for your tool. The page has ready snippets for Cursor, GitHub Copilot, Continue, Cline, Zed, n8n, the common SDKs, curl, MCP and OpenTelemetry exporters.
5. **Test.** SpanDock sends a request through its own public endpoint and shows the result.

### Port 443 on Linux

Linux lets only privileged processes use ports below 1024. The install script and the Ansible role already set this up. On a server you installed another way, use one of these:

1. **A systemd unit with `AmbientCapabilities=CAP_NET_BIND_SERVICE`** (recommended). SpanDock runs as its own user that owns its program, so it still updates itself, and systemd grants the permission on every start:

   ```ini
   [Service]
   User=spandock
   ExecStart=/var/lib/spandock/bin/spandock -role=server -accept-eula -open=false -menubar=false
   AmbientCapabilities=CAP_NET_BIND_SERVICE
   CapabilityBoundingSet=CAP_NET_BIND_SERVICE
   NoNewPrivileges=true
   Restart=always
   KillMode=process
   ```

   Keep `KillMode=process`: the update helper outlives the old process, checks the new version and rolls it back if it doesn't come up.
2. **Allow the port for every user:** `echo 'net.ipv4.ip_unprivileged_port_start=443' | sudo tee /etc/sysctl.d/50-spandock.conf && sudo sysctl --system`. Fine on a dedicated VM.
3. **A container:** listen on a high port and publish 443 to it, for example `-p 443:8443` with `SPANDOCK_PUBLIC_LISTEN=0.0.0.0:8443`.
4. **`setcap`** (last resort): `sudo setcap cap_net_bind_service=+ep "$(command -v spandock)"`. An update replaces the file and loses it; SpanDock then waits, and **Settings → Updates** shows the command to run before it installs.

## Networks that inspect HTTPS

Security tools such as Netskope, Zscaler, Palo Alto Prisma Access, Forcepoint and Cisco Umbrella open HTTPS and re-sign it with the organisation's own root certificate. SpanDock works behind them.

- **Trust.** SpanDock trusts the operating system's certificates, where IT usually installs the inspection certificate. You can also add it to SpanDock alone: **Settings → Network → TLS inspection → Add the organisation's CA**, or `spandock tls ca add company-root.pem`. On the server, `--managed` sends it to every client. `SPANDOCK_CA_FILE`, `SSL_CERT_FILE` and `NODE_EXTRA_CA_CERTS` work too.
- **Detection.** SpanDock notices an inspected connection and says so, by host name only, under **Settings → Network** and with `spandock tls status --check`.

Ask IT to exempt these hosts from inspection ("do not decrypt"), or at least to make sure the inspection certificate is trusted everywhere SpanDock runs:

1. **SpanDock's relays**, which carry the encrypted tunnel: the hosts listed under **Settings → Network → Relays**, plus `derp*.tailscale.com` as a last resort. Many inspecting proxies break the tunnel's long-lived connection. Its contents are end-to-end encrypted, so inspection sees nothing of them anyway.
2. **www.spandock.com** and **edge.spandock.com**: licensing, sign-in and the relay map.
3. **github.com**, **objects.githubusercontent.com** and **release-assets.githubusercontent.com**: updates.
4. **Your public endpoint**, if you have one.
5. **AI providers and destinations**, only if calls fail behind inspection.

## Updates and rollback

**On a VM**, choose how the server updates under **Settings → Updates**:

- **Automatically:** checks every 6 hours and installs new releases.
- **When I say:** shows new releases; you press **Install**.
- **Pinned:** runs exactly the version you enter, even an older one.

An update checks that the new version starts and answers; if it doesn't, the previous version comes back by itself. To go back to an earlier release on purpose, choose **Pinned** and enter that version (for example `0.65.0`). The install script takes `SPANDOCK_VERSION=v0.65.0` for the same.

When the server (the hub) updates, its satellites follow, one at a time, then its clients in batches, each to exactly the server's version and never past it. Turn this off under **Settings → Updates**.

**In a container,** SpanDock never updates itself; the image is the update:

```bash
docker pull ghcr.io/spandock/spandock && docker rm -f spandock   # then the same docker run as before
docker compose pull && docker compose up -d                       # Docker Compose
helm upgrade spandock oci://ghcr.io/spandock/charts/spandock --version 0.66.0 \
  --namespace spandock --reuse-values                             # Kubernetes
```

To pin or roll back, use a version tag (`ghcr.io/spandock/spandock:0.65.0`, or the chart's `--version`) instead of `latest`. Keep the same `/data` volume.

Release notes are on the [releases page](https://github.com/SpanDock/spandock-releases/releases).

## Backups

A server can back itself up, encrypted, to a bucket you own (S3, Cloudflare R2, Google Cloud Storage, Azure or any S3-compatible store): **Settings → Backups**, on Standard plans and higher and during the trial.

- Connect a bucket first under **Settings → Scaling → Object storage**.
- Setting up shows a **recovery key** once. Keep it in a password manager: without it, backups can't be restored, and neither the bucket's operator nor spandock.com can read them.
- To move or rebuild a server, keep the old one switched off and run `spandock backup restore` on the new machine (or choose **Restore it from a backup** on first launch), then activate it. It is the same server: clients and satellites reconnect by themselves.

On a container, also back up the `/data` volume with your platform's snapshots.

## Remove a server

1. **Release the license:** in the server's dashboard, **Settings → License → Deactivate**. This frees it on spandock.com.
2. **Delete what the deploy created:**

   | Where it runs | Remove it with |
   | --- | --- |
   | AWS | CloudFormation → the `spandock` stack → **Delete** (or `terraform destroy` for the Terraform kit) |
   | Azure | Delete the resource group you deployed into |
   | Google Cloud | `terraform destroy` in the same Cloud Shell folder |
   | Oracle Cloud | Resource Manager → the stack → **Destroy**, then **Delete stack** |
   | Render | The worker → **Settings → Delete service** (its disk goes with it) |
   | Fly.io | `fly apps destroy <app name>` |
   | Railway | The service → **Settings → Delete service**, and its volume |
   | Hetzner | `hcloud server delete spandock` |
   | DigitalOcean | `doctl compute droplet delete spandock` |
   | Docker | `docker rm -f spandock && docker volume rm spandock-data` |
   | Docker Compose | `docker compose down -v` |
   | Kubernetes | `helm uninstall spandock -n spandock`, then `kubectl delete pvc -n spandock data-spandock-0` (Helm keeps the volume) |

3. **On a Linux machine you keep** (installed with the script or Ansible):

   ```bash
   sudo systemctl disable --now spandock spandock-sidekick.service spandock-sidekick.path
   sudo rm -f /etc/systemd/system/spandock.service /etc/systemd/system/spandock-sidekick.* /usr/local/bin/spandock
   sudo systemctl daemon-reload
   sudo rm -rf /var/lib/spandock /etc/spandock && sudo userdel spandock
   ```

Deleting the volume or disk deletes the server's data and history for good. Back it up first if you may need it.

Removing a server disconnects its clients. To remove a satellite instead, disconnect it from the hub's **Cluster** page first, then delete it as above.

## More help

- Install SpanDock on Mac, Linux and Windows: [the releases page](https://github.com/SpanDock/spandock-releases#install)
- Sizes, kits and more: [Deploy in the cloud](https://www.spandock.com/docs/deploy) on spandock.com
- The deploy kits: [SpanDock/spandock-deploy](https://github.com/SpanDock/spandock-deploy)

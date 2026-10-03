# SpanDock releases

Downloads for **SpanDock**, a local gateway that collects OpenTelemetry traces, logs, and metrics from AI coding tools (Claude Code, Codex, Gemini CLI). It shows them on local dashboards, keeps them in an embedded DuckDB database, and forwards them to Langfuse, Grafana Cloud, New Relic, or any OTLP backend.

SpanDock is **one app**. On first launch it asks whether this computer is a **server** or a **client** (or standalone), and remembers the answer. Installed copies check the [latest release](https://github.com/SpanDock/spandock-releases/releases/latest) and update themselves.

## Install

**macOS (Homebrew, recommended; no "Open Anyway" prompt):**
```bash
brew install --cask spandock/spandock/spandock
```

**Linux, or a server VM:**
```bash
brew install spandock/spandock/spandock
spandock -role=server -open=false -menubar=false   # first start chooses the mode
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

## Other files

- `SpanDock-macos-<arch>.zip`, `spandock-<os>-<arch>.tar.gz`, `spandock-windows-<arch>.zip`: what the built-in updater downloads.
- `SpanDock-Server-…`, `SpanDock-Client-…`, `spandock-server-…`, `spandock-client-…`: the same build, under the names of the apps from before v0.6. Those apps keep updating from these files and stay in their mode.

## More

- Homebrew tap: [SpanDock/homebrew-spandock](https://github.com/SpanDock/homebrew-spandock)
- After installing, the dashboard opens at http://127.0.0.1:8787. Pair clients from the server's **Clients** page, and connect your AI tools under **Integrations**.

## License

SpanDock is proprietary software, free to use under the [End User License Agreement](https://www.spandock.com/legal/eula), with [paid plans](https://www.spandock.com/pricing) for larger teams. It is not open source. See [LICENSE](LICENSE). The open-source components it includes are listed in `THIRD_PARTY_NOTICES.txt` in each release.

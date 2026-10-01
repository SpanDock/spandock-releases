# SpanDock releases

Downloads for **SpanDock**, a local gateway that collects OpenTelemetry traces, logs, and metrics from AI coding tools (Claude Code, Codex, Gemini CLI) and routes them to Langfuse, Grafana Cloud, New Relic, any OTLP backend, or an embedded DuckDB database.

This repository holds release files only. Installed copies of SpanDock check its [latest release](https://github.com/h4ux/spandock-releases/releases/latest) and update themselves.

## Which file do I need?

| System | SpanDock Server | SpanDock Client |
| --- | --- | --- |
| macOS, Apple Silicon | `SpanDock-Server-<version>-macos-arm64.dmg` | `SpanDock-Client-<version>-macos-arm64.dmg` |
| macOS, Intel | `SpanDock-Server-<version>-macos-amd64.dmg` | `SpanDock-Client-<version>-macos-amd64.dmg` |
| Linux x86-64 | `spandock-server-linux-amd64.tar.gz` | `spandock-client-linux-amd64.tar.gz` |
| Linux ARM64 | `spandock-server-linux-arm64.tar.gz` | `spandock-client-linux-arm64.tar.gz` |
| Windows x86-64 | `spandock-server-windows-amd64.zip` | `spandock-client-windows-amd64.zip` |

The `SpanDock-*-macos-*.zip` files are what the in-app updater downloads; use the DMG to install by hand. Every file is listed with its SHA-256 in `checksums.txt`.

## Installing

**macOS:** open the DMG and drag the app to Applications. The apps are not yet notarized, so the first time, Control-click the app and choose **Open**.

**Linux:** `tar -xzf spandock-server-linux-amd64.tar.gz && ./spandock-server` (the dashboard opens at http://127.0.0.1:8787). Run it at login from **Settings → Open at login**, which installs a systemd user service.

**Windows:** unzip and run `spandock-server.exe` or `spandock-client.exe`.

Verify a download with `shasum -a 256 -c checksums.txt --ignore-missing` (macOS) or `sha256sum -c checksums.txt --ignore-missing` (Linux).

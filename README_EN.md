# V2RayN-PRO

**A ready-to-run v2rayN build tuned for Iran** — Iran geo data, Iran routing, DPI-resistant
TLS fragmentation and a WARP setup powered by [sing-box-plus](https://github.com/kyochikuto/sing-box-plus).

| Document language | Link |
|---|---|
| فارسی | [مستندات فارسی](./README.md) |
| English | **English document** |
| 中文 | [中文文档](./README_ZH.md) |
| Türkçe | [Türkçe dokümantasyon](./README_TUR.md) |

![V2RayN-PRO](./images/V2RaN.jpg)

---

## Download and run

1. Open the [Releases](https://github.com/RayanErfan/V2RayN-PRO/releases) page.
2. Download **`V2RayN-PRO-Windows-x64-*.zip`** and extract it anywhere (avoid `Program Files`).
3. Run `v2rayN.exe`. If you want TUN mode, run it as administrator.
4. Everything is preconfigured: English UI, Firefox fingerprint/User-Agent, fragment enabled,
   Iran routing selected, Iran geo files installed and WARP subscriptions added.

The SOCKS proxy listens on `127.0.0.1:10808` and the HTTP proxy on `127.0.0.1:10809`.

> Existing v2rayN users: download **`V2RayN-PRO-Configs-Only-*.zip`** instead and copy
> `guiConfigs` over your installation — **back up your current `guiConfigs` first**.

---

## What is included

| Component | Source | Why this build |
|---|---|---|
| v2rayN | [2dust/v2rayN](https://github.com/2dust/v2rayN) | GUI and config generator |
| Xray-core | [GFW-knocker/Xray-core](https://github.com/GFW-knocker/Xray-core) (MahsaNG) | WARP noise + extra DPI features |
| sing-box-plus | [kyochikuto/sing-box-plus](https://github.com/kyochikuto/sing-box-plus) | WARP endpoint scanner, handshake noise, TLS fragmentation |
| mihomo | [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) | Clash-compatible core |
| Geo data | [Chocolate4U/Iran-v2ray-rules](https://github.com/chocolate4u/Iran-v2ray-rules) | Iran-accurate `geoip`/`geosite` |
| Rule-sets | [Chocolate4U/Iran-sing-box-rules](https://github.com/Chocolate4U/Iran-sing-box-rules) | Iran-accurate `.srs` |

All components are updated automatically by the build workflow — see [Updating](#updating).

### Ready-made custom configs

The package ships four extra profiles (menu *Profiles → Custom configs*):

* **⚡️ Frag - WorkerLess** — Xray TLS-fragmentation profile for DPI bypass.
* **🕊 XRAY-WARP (GFW-knocker Mode)** — WireGuard-over-Xray with noise.
* **✨ WARP Proxy (use this with WireGuard)** — local WARP endpoint for WireGuard clients.
* **v2RayN-Pro SingBox Config** — sing-box-plus WARP profile with Iran rules
  (the default profile of the package).

WARP availability changes from day to day in Iran. If WARP does not connect, either enable the
endpoint scanner (see below) or use your own server/subscription — the routing, fragment and
geo setup keeps working with any node.

---

## PRO defaults (what is different from stock v2rayN)

1. English interface, Firefox TLS fingerprint and User-Agent.
2. Fragment enabled by default.
3. Iran routing selected (`v2RayN-Pro` routing rule).
4. Iran `geoip`/`geosite` data and Iran sing-box rule-sets.
5. System-compatible theme, real-time upload/download speed in the list.
6. WARP subscription plus PRO custom-config subscriptions.
7. Minimised start-up: only the tray icon and the main window are shown.
8. Subscriptions are fetched through jsDelivr (`cdn.jsdelivr.net`) because
   `raw.githubusercontent.com` is blocked in Iran.

### Enabling the WARP scanner

The scanner is shipped disabled so the core always starts. To let sing-box-plus find a working
WARP endpoint:

1. Open `guiConfigs/8e2b917c-0022-448f-9560-afff3ef870c3.json` (or the *v2RayN-Pro SingBox Config*
   profile → *Edit custom config*).
2. Set `"enable_ip_scanner": true` and `"enable_port_scanner": true` under `warp_scanner`.
3. Restart the profile. The first start can take a few seconds while the scanner runs.

---

## Updating

* **Full package** — download the newest release zip and replace the application files.
  Keep your own `guiConfigs` folder if you have personal servers/subscriptions.
* **Dependencies** — the GitHub Actions workflow checks upstream weekly and rebuilds the release
  when v2rayN, Xray, sing-box-plus, mihomo or the Iran geo data change.
* **Inside v2rayN** — the sing-box core is excluded from v2rayN's own updater on purpose:
  v2rayN would replace sing-box-plus with upstream sing-box and the WARP features would stop
  working. Update the sing-box core through a new PRO release instead.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `allowInsecure` error after importing an old node | Xray 26 removed `allowInsecure`. Use `verifyPeerCertByName` (e.g. `default.ssl.fastly.net` for Fastly fronts) or `pinnedPeerCertSha256`. |
| Core exits immediately | Port `10808`/`10809` already in use. Close the other proxy client or change the inbound port. |
| TUN mode not working | Run v2rayN as administrator; `wintun.dll` is bundled. |
| WARP connects but no internet | WARP is blocked by the ISP — use your own node, or enable the scanner and retry. |
| Iran sites go through the proxy | Select the `v2RayN-Pro` or `IR-ایران مستقیم، بقیه پراکسی` routing rule. |
| Subscription update fails | Use the jsDelivr mirror URLs (already configured), not `raw.githubusercontent.com`. |

---

## Building the package yourself

Requirements: PowerShell 5.1+ (Windows) or PowerShell 7, no .NET SDK needed.

```powershell
# build the full package + configs-only archive into ./output
./scripts/build-release.ps1 -Version V2RayN-PROv2.1

# pin component versions
./scripts/build-release.ps1 -Version test -V2rayNVersion 7.25.6 -XrayVersion v1.26.10-mahsa-r2

# only validate the repository configs against the latest cores
./scripts/build-release.ps1 -ValidateOnly
```

The build script downloads the components, assembles the package, validates every shipped
configuration with the bundled cores and writes `SHA256SUMS.txt` + `versions.json`.

---

## Credits

* [2dust/v2rayN](https://github.com/2dust/v2rayN) — the application.
* [lowercase78/V2RayN-PRO](https://github.com/lowercase78/V2RayN-PRO) — the original PRO idea.
* [GFW-knocker/Xray-core](https://github.com/GFW-knocker/Xray-core) and
  [kyochikuto/sing-box-plus](https://github.com/kyochikuto/sing-box-plus) — the cores.
* [Chocolate4U](https://github.com/chocolate4u) — Iran geo data and rule-sets.
* [MetaCubeX](https://github.com/MetaCubeX) — mihomo and geo databases.

## License

GPL-3.0 — see [LICENSE](./LICENSE). Each bundled component keeps its own license.

Hoping for freedom 🕊️

# Changelog

All notable changes to V2RayN-PRO are documented here.
The package version is independent from the bundled component versions; every release lists
the exact component versions in `versions.json` and in the release notes.

## V2RayN-PRO v2.1 — 2026-11-12

Full refresh of the distribution on top of v2rayN 7.25.6, with automated builds.

### Updated components

* v2rayN **7.25.6** (was 7.15.0 Pre).
* Xray-core MahsaNG **v1.26.10-mahsa-r2** (Xray 26.10.3 base, was 25.x).
* sing-box-plus **1.14.4** (was 1.10.x).
* mihomo **v1.19.34** (was 1.18.x).
* Iran geo data and sing-box rule-sets from the current Chocolate4U builds.

### Fixed

* **sing-box templates rewritten for sing-box 1.13/1.14.** The old template used inbound
  fields (`sniff_override_destination`, `domain_strategy`) that were removed in 1.13 and a
  legacy `udp://` DNS server format, so the default profile failed to start.
* **Remote rule-set download loop.** The sing-box WARP profile tried to download `.srs` files
  through WARP itself and crashed with `WireGuard is not ready yet`. Rule-sets now use an
  explicit direct HTTP client and are cached to disk.
* **Deprecated sing-box options removed.** Replaced `download_detour` with the 1.14
  `http_clients` / `default_http_client` mechanism.
* **Broken DNS rule** in the sing-box template (`domain: ir` combined with `domain_suffix`
  and `rule_set` in the same rule, which required all conditions at once).
* **Xray deprecation warnings.** `freedom.domainStrategy` moved to `sockopt.domainStrategy`,
  WebSocket `headers.Host` replaced by the new `host` field.
* **WARP scanner no longer aborts core startup.** The scanner is shipped disabled; enable it
  in the sing-box config when WARP is reachable.
* **Subscriptions fetched through jsDelivr** instead of `raw.githubusercontent.com`, which is
  blocked in Iran.
* **4,600 stale profiles removed** from the default database; the bundled subscriptions
  repopulate on first update. Only the PRO custom configs and WARP profiles are preinstalled.
* **sing-box excluded from v2rayN's own core updater** so sing-box-plus is not silently
  replaced by upstream sing-box.

### Added

* `scripts/build-release.ps1` — reproducible package builder (downloads, assembles, validates,
  zips, writes `SHA256SUMS.txt` and `versions.json`).
* `scripts/validate-configs.ps1` — validates every shipped config with the bundled cores.
* GitHub Actions `release.yml` — manual dispatch, tag push and weekly upstream check;
  publishes the Windows package and the configs-only archive.
* GitHub Actions `validate.yml` — validates the templates on every push/PR.
* Persian, English, Chinese and Turkish documentation rewritten.

### Changed

* `example/` binaries removed from git — packages are published as release assets only.
* Ports remain `10808` (SOCKS/mixed) and `10809` (HTTP).
* The Windows package is built from the multi-file `v2rayN-windows-64-desktop.zip` instead of
  the 170 MB single-file build (GitHub blocks files larger than 100 MB in git).

## V2RayN-PRO v2.0 — 2025-10-02

* v2rayN 7.15.0 Pre, sing-box 1.10, Xray 25.x.
* Added Iran sing-box rule-sets and WARP subscriptions.
* First release with four-language README.

## V1.9 and earlier

* Initial PRO distribution: preconfigured `guiConfigs`, five WARP servers, Iran routing and
  fragment enabled by default.

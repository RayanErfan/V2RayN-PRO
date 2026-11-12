# V2RayN-PRO

**面向伊朗用户的 v2rayN 集成包** — 伊朗 Geo 数据、伊朗分流规则、抗 DPI 的 TLS 分片，
以及基于 [sing-box-plus](https://github.com/kyochikuto/sing-box-plus) 的 WARP 配置。

| 文档语言 | 链接 |
|---|---|
| فارسی | [مستندات فارسی](./README.md) |
| English | [English document](./README_EN.md) |
| 中文 | **中文文档** |
| Türkçe | [Türkçe dokümantasyon](./README_TUR.md) |

![V2RayN-PRO](./images/V2RaN.jpg)

---

## 下载与运行

1. 打开 [Releases](https://github.com/RayanErfan/V2RayN-PRO/releases) 页面。
2. 下载 **`V2RayN-PRO-Windows-x64-*.zip`**，解压到任意目录（不要放在 `Program Files`）。
3. 运行 `v2rayN.exe`。如需 TUN 模式，请以管理员身份运行。
4. 全部已预配置：英文界面、Firefox 指纹与 User-Agent、默认启用分片、
   已选择伊朗分流、已安装伊朗 Geo 数据、已添加 WARP 订阅。

SOCKS 代理监听 `127.0.0.1:10808`，HTTP 代理监听 `127.0.0.1:10809`。

> 已有 v2rayN 用户：请下载 **`V2RayN-PRO-Configs-Only-*.zip`**，用其中的
> `guiConfigs` 覆盖原目录 —— **覆盖前请先备份**。

---

## 包含的组件

| 组件 | 来源 | 说明 |
|---|---|---|
| v2rayN | [2dust/v2rayN](https://github.com/2dust/v2rayN) | 图形界面与配置生成 |
| Xray-core | [GFW-knocker/Xray-core](https://github.com/GFW-knocker/Xray-core)（MahsaNG） | WARP 噪声与 DPI 特性 |
| sing-box-plus | [kyochikuto/sing-box-plus](https://github.com/kyochikuto/sing-box-plus) | WARP 端点扫描、握手噪声、TLS 分片 |
| mihomo | [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) | Clash 兼容内核 |
| Geo 数据 | [Chocolate4U/Iran-v2ray-rules](https://github.com/chocolate4u/Iran-v2ray-rules) | 伊朗精确 `geoip`/`geosite` |
| 规则集 | [Chocolate4U/Iran-sing-box-rules](https://github.com/Chocolate4U/Iran-sing-box-rules) | 伊朗 `.srs` 规则集 |

所有组件由 GitHub Actions 工作流自动更新。

### 预置自定义配置

* **⚡️ Frag - WorkerLess** — 无服务器 TLS 分片配置，用于绕过 DPI。
* **🕊 XRAY-WARP (GFW-knocker Mode)** — 带噪声的 Xray WARP。
* **✨ WARP Proxy (use this with WireGuard)** — 供 WireGuard 客户端使用的本地 WARP 端点。
* **v2RayN-Pro SingBox Config** — sing-box-plus WARP 配置（默认配置）。

伊朗的 WARP 可用性经常变化。若无法连接，请启用扫描器或使用自己的节点；
分流、分片与 Geo 设置对任何节点都有效。

---

## 与官方 v2rayN 的区别

1. 英文界面，Firefox 指纹与 User-Agent。
2. 默认启用分片（Fragment）。
3. 已选择伊朗分流规则（`v2RayN-Pro`）。
4. 伊朗 `geoip`/`geosite` 数据与伊朗 sing-box 规则集。
5. 跟随系统主题，列表显示实时上下行速度。
6. WARP 订阅与 PRO 自定义配置订阅。
7. 启动时最小化，仅显示托盘图标与主窗口。
8. 订阅通过 jsDelivr（`cdn.jsdelivr.net`）获取，因为 `raw.githubusercontent.com` 在伊朗被封锁。

### 启用 WARP 扫描器

扫描器默认关闭，确保内核总能启动。启用方法：

1. 打开 `guiConfigs/8e2b917c-0022-448f-9560-afff3ef870c3.json`
   （或配置文件 → *Edit custom config*）。
2. 在 `warp_scanner` 中设置 `"enable_ip_scanner": true` 与 `"enable_port_scanner": true`。
3. 重启该配置，首次启动会花几秒钟扫描。

---

## 更新

* **完整包** — 下载最新 Release 并替换程序文件；如需保留个人订阅，请保留自己的 `guiConfigs`。
* **依赖** — GitHub Actions 每周检查 v2rayN、Xray、sing-box-plus、mihomo 与伊朗 Geo 数据的更新，
  有变化时自动构建新 Release。
* **程序内更新** — sing-box 内核已从 v2rayN 自动更新中排除：v2rayN 会用官方 sing-box
  覆盖 sing-box-plus，导致 WARP 功能失效。请通过新的 PRO Release 更新该内核。

---

## 故障排除

| 问题 | 解决方法 |
|---|---|
| 导入旧节点后出现 `allowInsecure` 错误 | Xray 26 已移除 `allowInsecure`，请改用 `verifyPeerCertByName` 或 `pinnedPeerCertSha256`。 |
| 内核启动后立即退出 | 端口 `10808`/`10809` 被占用，请关闭其他代理或修改入站端口。 |
| TUN 模式无效 | 以管理员身份运行 v2rayN；`wintun.dll` 已随包提供。 |
| WARP 已连接但无网络 | WARP 被运营商封锁，请使用自己的节点或启用扫描器。 |
| 伊朗网站走了代理 | 选择 `v2RayN-Pro` 或 `IR-ایران مستقیم، بقیه پراکسی` 分流规则。 |
| 订阅更新失败 | 使用 jsDelivr 镜像地址（已配置），不要使用 `raw.githubusercontent.com`。 |

---

## 自行构建

需要 PowerShell 5.1+（Windows）或 PowerShell 7，无需 .NET SDK。

```powershell
./scripts/build-release.ps1 -Version V2RayN-PROv2.1
./scripts/build-release.ps1 -ValidateOnly
```

构建脚本会下载组件、组装发布包、用包内内核校验所有配置，
并生成 `SHA256SUMS.txt` 与 `versions.json`。

---

## 致谢

* [2dust/v2rayN](https://github.com/2dust/v2rayN)
* [lowercase78/V2RayN-PRO](https://github.com/lowercase78/V2RayN-PRO)
* [GFW-knocker/Xray-core](https://github.com/GFW-knocker/Xray-core)、
  [kyochikuto/sing-box-plus](https://github.com/kyochikuto/sing-box-plus)
* [Chocolate4U](https://github.com/chocolate4u)、[MetaCubeX](https://github.com/MetaCubeX)

## 许可证

GPL-3.0 — 见 [LICENSE](./LICENSE)。各组件保留自己的许可证。

Hoping for freedom 🕊️

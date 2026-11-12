# V2RayN-PRO

**İran için hazırlanmış v2rayN paketi** — İran Geo verisi, İran yönlendirme kuralları,
DPI atlatmak için TLS parçalama ve [sing-box-plus](https://github.com/kyochikuto/sing-box-plus)
tabanlı WARP yapılandırması.

| Belge dili | Bağlantı |
|---|---|
| فارسی | [مستندات فارسی](./README.md) |
| English | [English document](./README_EN.md) |
| 中文 | [中文文档](./README_ZH.md) |
| Türkçe | **Türkçe dokümantasyon** |

![V2RayN-PRO](./images/V2RaN.jpg)

---

## İndirme ve çalıştırma

1. [Releases](https://github.com/RayanErfan/V2RayN-PRO/releases) sayfasını açın.
2. **`V2RayN-PRO-Windows-x64-*.zip`** dosyasını indirip herhangi bir klasöre çıkarın
   (`Program Files` kullanmayın).
3. `v2rayN.exe` dosyasını çalıştırın. TUN modu için yönetici olarak çalıştırın.
4. Her şey hazırdır: İngilizce arayüz, Firefox parmak izi/User-Agent, etkin Fragment,
   İran yönlendirmesi, İran geo dosyaları ve WARP abonelikleri.

SOCKS proxy `127.0.0.1:10808`, HTTP proxy `127.0.0.1:10809` adresinde dinler.

> Mevcut v2rayN kullanıcıları: **`V2RayN-PRO-Configs-Only-*.zip`** dosyasını indirip
> `guiConfigs` klasörünü kopyalayın — **önce yedek alın**.

---

## Paket içeriği

| Bileşen | Kaynak | Neden bu sürüm |
|---|---|---|
| v2rayN | [2dust/v2rayN](https://github.com/2dust/v2rayN) | Arayüz ve yapılandırma üretimi |
| Xray-core | [GFW-knocker/Xray-core](https://github.com/GFW-knocker/Xray-core) (MahsaNG) | WARP noise ve DPI özellikleri |
| sing-box-plus | [kyochikuto/sing-box-plus](https://github.com/kyochikuto/sing-box-plus) | WARP endpoint tarayıcı, handshake noise, TLS parçalama |
| mihomo | [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) | Clash uyumlu çekirdek |
| Geo verisi | [Chocolate4U/Iran-v2ray-rules](https://github.com/chocolate4u/Iran-v2ray-rules) | İran için doğru `geoip`/`geosite` |
| Kural setleri | [Chocolate4U/Iran-sing-box-rules](https://github.com/Chocolate4U/Iran-sing-box-rules) | İran `.srs` kural setleri |

Tüm bileşenler GitHub Actions iş akışıyla otomatik güncellenir.

### Hazır özel yapılandırmalar

* **⚡️ Frag - WorkerLess** — Sunucusuz TLS parçalama ile DPI atlatma.
* **🕊 XRAY-WARP (GFW-knocker Mode)** — Noise ile Xray üzerinden WARP.
* **✨ WARP Proxy (use this with WireGuard)** — WireGuard istemcileri için yerel WARP endpoint.
* **v2RayN-Pro SingBox Config** — sing-box-plus WARP yapılandırması (varsayılan profil).

İran'da WARP erişilebilirliği değişkendir. Bağlanamazsanız tarayıcıyı etkinleştirin veya
kendi sunucunuzu kullanın — yönlendirme, Fragment ve geo ayarları her düğümle çalışır.

---

## PRO varsayılanları

1. İngilizce arayüz, Firefox TLS parmak izi ve User-Agent.
2. Fragment varsayılan olarak etkin.
3. İran yönlendirmesi seçili (`v2RayN-Pro` kuralı).
4. İran `geoip`/`geosite` verisi ve İran sing-box kural setleri.
5. Sistem teması ve listede canlı indirme/yükleme hızı.
6. WARP aboneliği ve PRO özel yapılandırma abonelikleri.
7. Simge durumuna küçültülmüş başlangıç.
8. Abonelikler jsDelivr (`cdn.jsdelivr.net`) üzerinden alınır, çünkü
   `raw.githubusercontent.com` İran'da engellidir.

### WARP tarayıcısını etkinleştirme

Tarayıcı, çekirdeğin her zaman başlaması için kapalı gelir. Açmak için:

1. `guiConfigs/8e2b917c-0022-448f-9560-afff3ef870c3.json` dosyasını açın
   (veya *Edit custom config*).
2. `warp_scanner` altında `"enable_ip_scanner": true` ve `"enable_port_scanner": true` yapın.
3. Profili yeniden başlatın; ilk başlatma tarama için birkaç saniye sürebilir.

---

## Güncelleme

* **Tam paket** — En yeni Release'i indirip uygulama dosyalarını değiştirin.
  Kişisel sunucularınız varsa kendi `guiConfigs` klasörünüzü koruyun.
* **Bağımlılıklar** — GitHub Actions haftalık olarak v2rayN, Xray, sing-box-plus, mihomo ve
  İran geo verisini kontrol eder, değişiklik varsa yeni Release oluşturur.
* **v2rayN içi güncelleme** — sing-box çekirdeği v2rayN güncelleyicisinden çıkarılmıştır;
  aksi halde resmi sing-box, sing-box-plus'ın yerine geçer ve WARP özellikleri çalışmaz.
  Çekirdeği yeni PRO Release ile güncelleyin.

---

## Sorun giderme

| Sorun | Çözüm |
|---|---|
| Eski düğümde `allowInsecure` hatası | Xray 26 `allowInsecure` alanını kaldırdı; `verifyPeerCertByName` veya `pinnedPeerCertSha256` kullanın. |
| Çekirdek hemen kapanıyor | `10808`/`10809` portu kullanımda; diğer proxy'yi kapatın veya portu değiştirin. |
| TUN çalışmıyor | v2rayN'i yönetici olarak çalıştırın; `wintun.dll` pakette. |
| WARP bağlanıyor ama internet yok | WARP ISS tarafından engellenmiş; kendi düğümünüzü kullanın veya tarayıcıyı açın. |
| İran siteleri proxy'den geçiyor | `v2RayN-Pro` veya `IR-ایران مستقیم، بقیه پراکسی` kuralını seçin. |
| Abonelik güncellenmiyor | jsDelivr adreslerini kullanın (hazır), `raw.githubusercontent.com` değil. |

---

## Paketi kendiniz derleyin

Gereksinim: PowerShell 5.1+ (Windows) veya PowerShell 7. .NET SDK gerekmez.

```powershell
./scripts/build-release.ps1 -Version V2RayN-PROv2.1
./scripts/build-release.ps1 -ValidateOnly
```

Betik bileşenleri indirir, paketi oluşturur, tüm yapılandırmaları paket içindeki
çekirdeklerle doğrular ve `SHA256SUMS.txt` + `versions.json` yazar.

---

## Teşekkürler

* [2dust/v2rayN](https://github.com/2dust/v2rayN)
* [lowercase78/V2RayN-PRO](https://github.com/lowercase78/V2RayN-PRO)
* [GFW-knocker/Xray-core](https://github.com/GFW-knocker/Xray-core)、
  [kyochikuto/sing-box-plus](https://github.com/kyochikuto/sing-box-plus)
* [Chocolate4U](https://github.com/chocolate4u)、[MetaCubeX](https://github.com/MetaCubeX)

## Lisans

GPL-3.0 — [LICENSE](./LICENSE). Her bileşen kendi lisansını korur.

Hoping for freedom 🕊️

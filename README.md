# V2RayN-PRO

**نسخه آماده‌به‌کار v2rayN مخصوص ایران** — داده‌های جغرافیایی ایران، روتینگ ایران،
Fragment برای دور زدن DPI و یک پروفایل WARP بر پایه [sing-box-plus](https://github.com/kyochikuto/sing-box-plus).

| زبان مستند | لینک |
|---|---|
| فارسی | **مستندات فارسی** |
| English | [English document](./README_EN.md) |
| 中文 | [中文文档](./README_ZH.md) |
| Türkçe | [Türkçe dokümantasyon](./README_TUR.md) |

![V2RayN-PRO](./images/V2RaN.jpg)

---

## دانلود و اجرا

1. به صفحه [Releases](https://github.com/RayanErfan/V2RayN-PRO/releases) بروید.
2. فایل **`V2RayN-PRO-Windows-x64-*.zip`** را دانلود و هر جایی (به‌جز `Program Files`) از حالت فشرده خارج کنید.
3. فایل `v2rayN.exe` را اجرا کنید. اگر می‌خواهید از TUN استفاده کنید، برنامه را با دسترسی Administrator اجرا کنید.
4. همه‌چیز از قبل تنظیم شده است: رابط انگلیسی، فینگرپرینت و User-Agent فایرفاکس، Fragment فعال،
   روتینگ ایران انتخاب‌شده، دیتای geo ایران نصب‌شده و ساب‌های WARP اضافه‌شده.

پروکسی SOCKS روی `127.0.0.1:10808` و پروکسی HTTP روی `127.0.0.1:10809` گوش می‌دهد.

> اگر از قبل v2rayN دارید: فایل **`V2RayN-PRO-Configs-Only-*.zip`** را دانلود کنید و پوشه
> `guiConfigs` را روی نصب فعلی کپی کنید — **قبل از هر تغییری از `guiConfigs` بکاپ بگیرید**.

---

## چه چیزهایی داخل بسته است؟

| جزء | منبع | دلیل استفاده |
|---|---|---|
| v2rayN | [2dust/v2rayN](https://github.com/2dust/v2rayN) | رابط کاربری و تولید کانفیگ |
| Xray-core | [GFW-knocker/Xray-core](https://github.com/GFW-knocker/Xray-core) (MahsaNG) | نویز WARP و قابلیت‌های DPI |
| sing-box-plus | [kyochikuto/sing-box-plus](https://github.com/kyochikuto/sing-box-plus) | اسکنر endpoint و نویز WARP، Fragment |
| mihomo | [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) | هسته سازگار با Clash |
| دیتای جغرافیایی | [Chocolate4U/Iran-v2ray-rules](https://github.com/chocolate4u/Iran-v2ray-rules) | `geoip`/`geosite` دقیق ایران |
| Rule-set | [Chocolate4U/Iran-sing-box-rules](https://github.com/Chocolate4U/Iran-sing-box-rules) | فایل‌های `.srs` ایران |

همه اجزا به‌صورت خودکار توسط GitHub Actions به‌روزرسانی می‌شوند — بخش [به‌روزرسانی](#بهروزرسانی) را ببینید.

### کانفیگ‌های آماده

بسته چهار پروفایل اضافه دارد (منوی *Profiles → Custom configs*):

* **⚡️ Frag - WorkerLess** — پروفایل Fragment برای عبور از DPI بدون سرور.
* **🕊 XRAY-WARP (GFW-knocker Mode)** — WARP روی Xray با نویز.
* **✨ WARP Proxy (use this with WireGuard)** — endpoint محلی WARP برای کلاینت‌های WireGuard.
* **v2RayN-Pro SingBox Config** — پروفایل WARP با sing-box-plus و قوانین ایران
  (پروفایل پیش‌فرض بسته).

وضعیت WARP در ایران روزبه‌روز تغییر می‌کند. اگر WARP وصل نشد، اسکنر را فعال کنید (پایین‌تر)
یا از سرور/ساب خودتان استفاده کنید — روتینگ، Fragment و دیتای geo با هر نودی کار می‌کند.

---

## تنظیمات پیش‌فرض PRO (تفاوت با v2rayN معمولی)

۱. رابط انگلیسی، فینگرپرینت و User-Agent فایرفاکس.
۲. Fragment به‌صورت پیش‌فرض فعال.
۳. روتینگ ایران انتخاب‌شده (قانون `v2RayN-Pro`).
۴. دیتای `geoip`/`geosite` ایران و rule-setهای sing-box ایران.
۵. تم سازگار با سیستم و نمایش سرعت دانلود/آپلود.
۶. ساب WARP به‌همراه ساب‌های Custom config پروژه.
۷. اجرای سبک در استارت‌آپ: فقط آیکون Tray و پنجره اصلی.
۸. ساب‌ها از طریق jsDelivr (`cdn.jsdelivr.net`) دریافت می‌شوند، چون
   `raw.githubusercontent.com` در ایران مسدود است.

### فعال کردن اسکنر WARP

اسکنر به‌صورت پیش‌فرض خاموش است تا هسته همیشه بالا بیاید. برای اینکه sing-box-plus
یک endpoint سالم WARP پیدا کند:

1. فایل `guiConfigs/8e2b917c-0022-448f-9560-afff3ef870c3.json` را باز کنید
   (یا پروفایل *v2RayN-Pro SingBox Config* → *Edit custom config*).
2. در بخش `warp_scanner` مقدار `"enable_ip_scanner": true` و `"enable_port_scanner": true` را قرار دهید.
3. پروفایل را دوباره اجرا کنید. اولین اجرا چند ثانیه طول می‌کشد تا اسکن تمام شود.

---

## به‌روزرسانی

* **بسته کامل** — آخرین Release را دانلود کنید و فایل‌های برنامه را جایگزین کنید.
  اگر سرور/ساب شخصی دارید، پوشه `guiConfigs` خودتان را نگه دارید.
* **وابستگی‌ها** — ورک‌فلوی GitHub Actions هر هفته نسخه‌های جدید v2rayN، Xray،
  sing-box-plus، mihomo و دیتای geo ایران را بررسی می‌کند و در صورت تغییر، Release جدید می‌سازد.
* **داخل خود v2rayN** — هسته sing-box عمداً از آپدیتر داخلی v2rayN حذف شده است؛
  چون v2rayN نسخه رسمی sing-box را جایگزین می‌کند و قابلیت‌های WARP از کار می‌افتد.
  هسته sing-box را فقط از طریق Release جدید PRO به‌روز کنید.

---

## رفع اشکال

| مشکل | راه‌حل |
|---|---|
| خطای `allowInsecure` بعد از ایمپورت نود قدیمی | در Xray 26 فیلد `allowInsecure` حذف شده است. از `verifyPeerCertByName` (مثلاً `default.ssl.fastly.net` برای Fastly) یا `pinnedPeerCertSha256` استفاده کنید. |
| هسته بلافاصله بسته می‌شود | پورت `10808`/`10809` اشغال است. برنامه پروکسی دیگر را ببندید یا پورت inbound را عوض کنید. |
| TUN کار نمی‌کند | v2rayN را با دسترسی Administrator اجرا کنید؛ `wintun.dll` همراه بسته است. |
| WARP وصل می‌شود ولی اینترنت ندارد | WARP توسط ISP مسدود شده — از نود خودتان استفاده کنید یا اسکنر را فعال کنید. |
| سایت‌های ایرانی از پروکسی رد می‌شوند | قانون روتینگ `v2RayN-Pro` یا `IR-ایران مستقیم، بقیه پراکسی` را انتخاب کنید. |
| آپدیت ساب شکست می‌خورد | از آدرس‌های jsDelivr استفاده کنید (از قبل تنظیم شده)، نه `raw.githubusercontent.com`. |

---

## ساخت بسته به‌صورت دستی

نیازمندی: PowerShell 5.1+ (ویندوز) یا PowerShell 7. نیازی به .NET SDK نیست.

```powershell
# ساخت بسته کامل و آرشیو کانفیگ‌ها در پوشه ./output
./scripts/build-release.ps1 -Version V2RayN-PROv2.1

# ساخت با نسخه‌های مشخص
./scripts/build-release.ps1 -Version test -V2rayNVersion 7.25.6 -XrayVersion v1.26.10-mahsa-r2

# فقط اعتبارسنجی کانفیگ‌های مخزن با آخرین هسته‌ها
./scripts/build-release.ps1 -ValidateOnly
```

اسکریپت ساخت، اجزا را دانلود می‌کند، بسته را می‌سازد، تمام کانفیگ‌ها را با هسته‌های داخل بسته
اعتبارسنجی می‌کند و فایل‌های `SHA256SUMS.txt` و `versions.json` را می‌نویسد.

---

## اعتبارها

* [2dust/v2rayN](https://github.com/2dust/v2rayN) — برنامه اصلی.
* [lowercase78/V2RayN-PRO](https://github.com/lowercase78/V2RayN-PRO) — ایده اولیه PRO.
* [GFW-knocker/Xray-core](https://github.com/GFW-knocker/Xray-core) و
  [kyochikuto/sing-box-plus](https://github.com/kyochikuto/sing-box-plus) — هسته‌ها.
* [Chocolate4U](https://github.com/chocolate4u) — دیتای geo و rule-set ایران.
* [MetaCubeX](https://github.com/MetaCubeX) — mihomo و دیتابیس‌های geo.

## مجوز

GPL-3.0 — فایل [LICENSE](./LICENSE) را ببینید. هر جزء داخل بسته مجوز خودش را دارد.

به امید آزادی 🕊️

[English](README.md) | [简体中文](/docs/README_CN.md) | **Türkçe**

# KernelSU Next

<img src="/assets/kernelsu_next.png" style="width: 96px;" alt="logo">

Android cihazlar için Kernel tabanlı bir root çözümü.

[![Latest release](https://img.shields.io/github/v/release/rifsxd/KernelSU-Next?label=Release&logo=github)](https://github.com/rifsxd/KernelSU-Next/releases/latest)
[![Nightly Release](https://img.shields.io/badge/Nightly%20release-gray?logo=hackthebox&logoColor=fff)](https://nightly.link/rifsxd/KernelSU-Next/workflows/build-manager/next/manager)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-orange.svg?logo=gnu)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![GitHub License](https://img.shields.io/github/license/rifsxd/KernelSU-Next?logo=gnu)](/LICENSE)

## Özellikler

1. Çekirdek tabanlı `su` ve kök erişim yönetimi.
2. [OverlayFS](https://en.wikipedia.org/wiki/OverlayFS) tabanlı modül sistemi.
3. [App Profile](https://kernelsu.org/guide/app-profile.html): Kök gücünü bir kafese kilitleyin.

## Uyumluluk Durumu

KernelSU Next, 4.9'dan başlayarak 6.6'ya kadar çoğu Android çekirdeğini resmi olarak desteklemektedir.
 - GKI 2.0 (5.10+) çekirdekleri önceden oluşturulmuş görüntüleri ve LKM/KMI'yi çalıştırabilir.
 - GKI 1.0 (4.19 - 5.4) çekirdeklerinin KernelSU sürücüsü ile yeniden oluşturulması gerekir.
 - EOL (<4.19) çekirdeklerinin de KernelSU sürücüsü ile yeniden oluşturulması gerekir.

Şu anda sadece `arm64-v8a` desteklenmektedir.

## Güvenlik

KernelSU'daki güvenlik açıklarını bildirme hakkında bilgi için [SECURITY.md](/SECURITY.md) bölümüne bakın.

## Lisans

- `kernel` dizini altındaki dosyalar sadece [GPL-2.0](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html) lisansına tabiidir.
- `kernel` dizini dışındaki diğer tüm kısımlar [GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.html) ya da daha sonraki bir sürüm lisansa tabiidir.

## Krediler

- [kernel-assisted-superuser](https://git.zx2c4.com/kernel-assisted-superuser/about/): KernelSU fikri.
- [Magisk](https://github.com/topjohnwu/Magisk): güçlü kök aracı.
- [genuine](https://github.com/brevent/genuine/): apk v2 imza doğrulama.
- [Diamorphine](https://github.com/m0nad/Diamorphine): bazı rootkit becerileri.
- [KernelSU](https://github.com/tiann/KernelSU): tiann'a teşekkürler, yoksa KernelSU Next var olamazdı bile.

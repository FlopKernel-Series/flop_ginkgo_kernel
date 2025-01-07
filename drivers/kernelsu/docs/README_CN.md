[English](README.md) | **简体中文** | [Türkçe](README_TR.md)

# KernelSU Next

<img src="/assets/kernelsu_next.png" style="width: 96px;" alt="logo">

安卓基于内核的 Root 方案

[![Latest release](https://img.shields.io/github/v/release/rifsxd/KernelSU-Next?label=Release&logo=github)](https://github.com/rifsxd/KernelSU-Next/releases/latest)
[![Nightly Release](https://img.shields.io/badge/Nightly%20release-gray?logo=hackthebox&logoColor=fff)](https://nightly.link/rifsxd/KernelSU-Next/workflows/build-manager/next/manager)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-orange.svg?logo=gnu)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![GitHub License](https://img.shields.io/github/license/rifsxd/KernelSU-Next?logo=gnu)](/LICENSE)

## 特性

1. 基于内核的 SU 和权限管理
2. 基于 [Magic Mount](https://github.com/topjohnwu/Magisk/blob/c512496847d182526f2043295ecfd275398eccac/docs/releases/26100.md#new-magic-mount-implementation) 的模块系统
3. [App Profile](https://kernelsu.org/guide/app-profile.html)：把 Root 权限关进笼子里

## 兼容状态

KernelSU Next 支持从 4.4 到 6.6 的大多数安卓内核
 - GKI 2.0（5.10+）内核可运行预置镜像和 LKM/KMI
 - GKI 1.0（4.19 - 5.4）内核需要使用 KernelSU 内核驱动重新编译
 - EOL (<4.14) 内核也需要使用 KernelSU 内核驱动重新编译 (3.18+ 這是一個實驗版本，可能需要一些功能回溯。)

目前只支持 `arm64-v8a` 架构

## 安全性

有关报告 KernelSU Next 漏洞的信息，请参阅 [SECURITY.md](/SECURITY.md).

## 许可证

- 目录 `kernel` 下所有文件为 [GPL-2.0-only](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
- `kernel` 目录以外的其他部分均为 [GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.html)

## 鸣谢

- [kernel-assisted-superuser](https://git.zx2c4.com/kernel-assisted-superuser/about/): KernelSU 的灵感.
- [Magisk](https://github.com/topjohnwu/Magisk): 强大的 Root 工具.
- [genuine](https://github.com/brevent/genuine/): apk v2 签名验证。
- [Diamorphine](https://github.com/m0nad/Diamorphine): 一些 Rootkit 技巧。
- [KernelSU](https://github.com/tiann/KernelSU): 感谢 tiann，否则 KernelSU Next 根本不会存在。
- [Magic Mount Port](https://github.com/5ec1cff/KernelSU/blob/main/userspace/ksud/src/magic_mount.rs): 💜 5ec1cff 為了拯救 KernelSU！

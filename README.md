# KernelSU Next

<img src="assets/kernelsu_next.png" style="width: 96px;" alt="logo">

A Kernel-based root solution for Android devices.

[![Latest release](https://img.shields.io/github/v/release/rifsxd/KernelSU?label=Release&logo=github)](https://github.com/rifsxd/KernelSU/releases/latest)
[![Nightly Release](https://img.shields.io/badge/Nightly%20release-gray?logo=hackthebox&logoColor=fff)](https://nightly.link/rifsxd/KernelSU/workflows/build-manager/next/manager)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-orange.svg?logo=gnu)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![GitHub License](https://img.shields.io/github/license/tiann/KernelSU?logo=gnu)](/LICENSE)

## Features

1. Kernel-based `su` and root access management.
2. Module system based on [Magic Mount](https://github.com/topjohnwu/Magisk/blob/c512496847d182526f2043295ecfd275398eccac/docs/releases/26100.md#new-magic-mount-implementation).
3. [App Profile](https://kernelsu.org/guide/app-profile.html): Lock up the root power in a cage.

## Compatibility State

KernelSU Next officially supports most Android kernels starting from 4.14 upto 6.6.
 - GKI 2.0 (5.10+) kernels can run pre-built images and LKM/KMI.
 - GKI 1.0 (4.19 - 5.4) kernels need to rebuilt with KernelSU driver.
 - EOL (<4.19) kernels also need to be rebuilt with KernelSU driver. (3.18+ is experimental)

Currently, only `arm64-v8a` is supported.

## Usage

- [Installation Instruction](https://kernelsu.org/guide/installation.html)
- [How to build?](https://kernelsu.org/guide/how-to-build.html)
- [Official Website](https://kernelsu.org/)

## Security

For information on reporting security vulnerabilities in KernelSU, see [SECURITY.md](/SECURITY.md).

## License

- Files under the `kernel` directory are [GPL-2.0-only](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html).
- All other parts except the `kernel` directory are [GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.html).

## Credits

- [kernel-assisted-superuser](https://git.zx2c4.com/kernel-assisted-superuser/about/): the KernelSU idea.
- [Magisk](https://github.com/topjohnwu/Magisk): the powerful root tool.
- [genuine](https://github.com/brevent/genuine/): apk v2 signature validation.
- [Diamorphine](https://github.com/m0nad/Diamorphine): some rootkit skills.
- [KernelSU](https://github.com/tiann/KernelSU): thanks to tiann or else KernelSU Next wouldn't even exist.
- [Magic Mount Port](https://github.com/5ec1cff/KernelSU/blob/main/userspace/ksud/src/magic_mount.rs): 💜 5ec1cff for saving KernelSU!

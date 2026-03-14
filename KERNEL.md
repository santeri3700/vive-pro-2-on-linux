# Linux with VIVE Pro 2 patches

Kernel patches created by [CertainLach](https://github.com/CertainLach/VivePro2-Linux-Driver/).

**NOTE:** The custom kernel is only designed to be installed on Arch Linux. \
If you are on another distribution, will have to find out how to patch and compile a kernel on it (see CertainLach's repository). \
I personally do not recommend using anything else than a bleeding edge distro for this at the moment. \
See Kernel Patches section below for the patches used in this guide.

### Enter the kernel directory
- `cd kernel/`

### Build and install the patched kernel

#### Import GPG keys
- `for key in ./keys/pgp/*.asc; do gpg --import $key; done`

#### Build the custom kernel
- `export MAKEFLAGS="-j $(nproc)"`
- `makepkg -sc`

#### Install the custom kernel and update the bootloader (e.g. GRUB)
- `makepkg -si`
- `sudo grub-mkconfig -o /boot/grub/grub.cfg`

### Reboot and ensure you've booted with the patched kernel
- `uname -r` should print `6.x.x-arch1-1-vivepro2`
- You can now proceed with setting up SteamVR and/or the FOSS VR alternatives.

## Kernel Patches
- **[PATCH v7 1/7] drm/edid: rename VESA block parsing functions to more generic name**
  - Source: https://lore.kernel.org/all/20251202110218.9212-2-iam@lach.pw/
  - Patch file: [0001-drm-edid-rename-VESA-block-parsing-functions-to-more-generic-name_v7.patch](./kernel/0001-drm-edid-rename-VESA-block-parsing-functions-to-more-generic-name_v7.patch)
- **[PATCH v7 2/7] drm/edid: prepare for VESA vendor-specific data block extension**
  - Source: https://lore.kernel.org/all/20251202110218.9212-3-iam@lach.pw/
  - Patch file: [0002-drm-edid-prepare-for-VESA-vendor-specific-data-block-extension_v7.patch](./kernel/0002-drm-edid-prepare-for-VESA-vendor-specific-data-block-extension_v7.patch)
- **[PATCH v7 3/7] drm/edid: MSO should only be used for non-eDP displays**
  - Source: https://lore.kernel.org/all/20251202110218.9212-4-iam@lach.pw/
  - Patch file: [0003-drm-edid-MSO-should-only-be-used-for-non-eDP-displays_v7.patch](./kernel/0003-drm-edid-MSO-should-only-be-used-for-non-eDP-displays_v7.patch)
- **[PATCH v7 4/7] drm/edid: parse DSC DPP passthru support flag for mode VII timings**
  - Source: https://lore.kernel.org/all/20251202110218.9212-5-iam@lach.pw/
  - Patch file: [0004-drm-edid-parse-DSC-DPP-passthru-support-flag-for-mode-VII-timings_v7.patch](./kernel/0004-drm-edid-parse-DSC-DPP-passthru-support-flag-for-mode-VII-timings_v7.patch)
- **[PATCH v7 5/7] drm/edid: for consistency, use mask everywhere for block rev parsing**
  - Source: https://lore.kernel.org/all/20251202110218.9212-6-iam@lach.pw/
  - Patch file: [0005-drm-edid-for-consistency-use-mask-everywhere-for-block-rev-parsing_v7.patch](./kernel/0005-drm-edid-for-consistency-use-mask-everywhere-for-block-rev-parsing_v7.patch)
- **[PATCH v7 6/7] drm/edid: parse DRM VESA dsc bpp target**
  - Source: https://lore.kernel.org/all/20251202110218.9212-7-iam@lach.pw/
  - Patch file: [0006-drm-edid-parse-DRM-VESA-dsc-bpp-target_v7.patch](./kernel/0006-drm-edid-parse-DRM-VESA-dsc-bpp-target_v7.patch)
- **[PATCH v7 7/7] drm/amd: use fixed dsc bits-per-pixel from edid**
  - Source: https://lore.kernel.org/all/20251202110218.9212-8-iam@lach.pw/
  - Patch file: [0007-drm-amd-use-fixed-dsc-bits-per-pixel-from-edid_v7.patch](./kernel/0007-drm-amd-use-fixed-dsc-bits-per-pixel-from-edid_v7.patch)
- **[PATCH] drm/edid: Add Vive Pro 2 to non-desktop list** (not needed since Linux 6.4): https://lkml.org/lkml/2022/1/18/693
  - Diff: https://lkml.org/lkml/diff/2022/1/18/693/1
  - GitHub: https://github.com/CertainLach/VivePro2-Linux-Driver/blob/master/kernel-patches/0001-drm-edid-non-desktop.patch
- **[PATCH v2] drm/edid: Support type 7 timings** (merged to upstream in Linux 5.18): https://lkml.org/lkml/2022/1/23/302
  - Merged to upstream: https://github.com/torvalds/linux/commit/80ecb5d7c0f224218fdf956faec0ebe73d79f53d
  - Diff: https://lkml.org/lkml/diff/2022/1/23/302/1
  - GitHub: https://github.com/CertainLach/VivePro2-Linux-Driver/blob/master/kernel-patches/0002-drm-edid-type-7-timings.patch
- **[PATCH v2 1/2] drm/edid: parse DRM VESA dsc bpp target** (superseded by newer patches): https://lkml.org/lkml/2022/2/20/151
  - Diff: https://lkml.org/lkml/diff/2022/2/20/151/1
  - GitHub: https://github.com/CertainLach/VivePro2-Linux-Driver/blob/master/kernel-patches/0003-drm-edid-dsc-bpp-parse.patch
- **[PATCH v2 2/2] drm/amd: use fixed dsc bits-per-pixel from edid** (superseded by newer patches): https://lkml.org/lkml/2022/2/20/153
  - Diff: https://lkml.org/lkml/diff/2022/2/20/153/1
  - GitHub: https://github.com/CertainLach/VivePro2-Linux-Driver/blob/master/kernel-patches/0004-drm-amd-dsc-bpp-apply.patch
- **[PATCH 1/1] HID: hidraw: Replace hidraw device table mutex with a rwsem** (merged upstream): https://lkml.org/lkml/2021/11/30/545
  - Merged upstream: https://github.com/torvalds/linux/commit/8590222e4b021054a7167a4dd35b152a8ed7018e
  - Diff: https://lkml.org/lkml/diff/2021/11/30/545/1

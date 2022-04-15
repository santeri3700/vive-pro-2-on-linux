# linux-vivepro2

This guide is meant for tinkerers who know their way around. \
I do not recommend attempting to use the VIVE Pro 2 on anything other than bleeding edge systems (such as Arch Linux) \
The VR experience on Linux as of 2022-04-15 is mediocre at best especially on the newer hardware such as the VIVE Pro 2. \
I can't recommend using SteamVR on Linux at the moment so consider this as experimentation rather than entertainment for now.

---

## WORK IN PROGRESS
**Updated**: 2022-04-15

### Tested and working
- Headset, controllers and base stations (connection, picture, tracking etc..)
- Audio output

### Tested and not working
- VIVE Console software (GUI utilities etc)
- Focus knob overlay (possibly a part of the VIVE Console software). Focusing does work, but there is no visual helper.

### Untested
- Firmware updates
- Microphone (probably works)
- Front facing cameras or Camera view
- Desktop view (probably doesn't work because of general SteamVR issues)
- VIVE Wireless Adapter (I don't have one)
- VIVE Tracker (I don't have any)
- 3rd party USB peripherals/accessories (I don't have any)

---

## Setup
**NOTE:** The custom kernel is only designed to be installed on Arch Linux. \
If you are on another distribution, will have to find out how to patch and compile a kernel on it. \
See Kernel Patches section below for the patches used in this guide.

### Build and install patched kernel
Kernel version: 5.17.2
#### Copy your current kernel config
**NOTE**: If you are currently running Linux version other than 5.17.x, you might have to update the config.
- `mkdir -p ~/.config/linux-vivepro2/`
- `zcat /proc/config.gz > ~/.config/linux-vivepro2/myconfig`
#### Build the custom kernel
- `export MAKEFLAGS="-j $(nproc)"`
- `env use_numa=n use_tracers=n makepkg -sc`
#### Install the custom kernel and update the bootloader (e.g. GRUB)
- `makepkg -si`
- `sudo grub-mkconfig -o /boot/grub/grub.cfg`
- `sudo grub-install`

### Install SteamVR and VIVE Console for SteamVR
Install both apps from Steam and **close Steam after they've been installed**. \
VIVE Console is only required for the viveVR driver and is not used in runtime.
- SteamVR:
  - [steam://install/250820](steam://install/250820)
  - https://store.steampowered.com/app/250820/
- VIVE Console for SteamVR:
  - [steam://install/1635730](steam://install/1635730) 
  - https://store.steampowered.com/app/1635730/

### Install VIVE Pro 2 Linux Driver by CertainLach
#### Install dependencies
- `sudo pacman -S git rustup`
- `sudo pacman -S mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads`
- `sudo pacman -S wine` or `sudo pacman -S wine-staging`

#### Install/Update nightly version of Rust for Windows x86_64 target
- `rustup +nightly-2022-03-14 target add x86_64-pc-windows-gnu`

#### Clone the driver repository
- `git clone https://github.com/CertainLach/VivePro2-Linux-Driver.git`
#### Build the lens server
- `cd VivePro2-Linux-Driver/bin/lens-driver`
- `cargo +nightly-2022-03-14 build --release --target x86_64-pc-windows-gnu --all-features --verbose`
#### Build the lighhouse proxy driver
- `cd ../../`
- `cargo +nightly-2022-03-14 build --release --all-features --verbose`
#### Copy the compiled objects to the dist directory
- `cp target/x86_64-pc-windows-gnu/release/lens-server.exe dist/lens-server/`
- `cp target/release/libdriver_lighthouse.so dist/driver_lighthouse.so`
#### Run the install script to install the components
- `cd dist`
- `./install.sh`

---

## Playing in VR

### Connect the headset to your PC like shown in the official guide
You can check the output of `lsusb` and `sudo dmesg` to verify connectivity.

### Make sure Wine is properly installed system wide
- `wine64 --version`
- `wine64 winecfg`

### Add CAP_SYS_NICE capability for SteamVR compositor
This is done beforehand to avoid issues where Steam would require superuser access when launching SteamVR. \
It should also improve performance and latency. \
**WARNING! This enables SteamVR's "Asynchronous Reprojection" which is partially broken as of SteamVR version 1.12.6 (2022-04-12). See Workaround below**
- `cd ~/.steam/steam/steamapps/common/SteamVR/`
- `sudo setcap CAP_SYS_NICE=eip ./bin/linux64/vrcompositor-launcher`

### Launch Steam and start SteamVR
- Everything should work without additional setup.
- Complete the Room Setup like you would normally do.
- There are some issues in the current versions of SteamVR, check the Known issues and Troubleshooting sections for more information.

---

## Known issues & Workarounds
- Headset displays nothing and SteamVR fails to enable Direct Display Mode
  - This might be caused because of the missing kernel patches. The VIVE Pro 2 is not fully supported in the official releases of the Linux kernel as of 2022-04-15.
  - Wayland compatibility is a hit or miss (at least on SwayWM). Please open an issue if you have a workaround or tips regarding this.
  - Issue: https://github.com/ValveSoftware/SteamVR-for-Linux/issues/450

- Visual artifacts (such as green pixel snow) caused by the "Asynchronous Reprojection".
  - Add `"enableLinuxVulkanAsync" : false,` under the `steamvr` section (above "installID") in the `steamvr.vrsettings` file:
    ```
    "steamvr" : {
      "enableLinuxVulkanAsync" : false,
      "installID" : "xxxxxx",
      "lastVersionNotice" : "x.xx.x",
      ...
    ```
  - `steamvr.vrsettings` can be usually found at `~/.steam/steam/config/steamvr.vrsettings`
  - This can reduce performance and smoothness depending on your hardware. With an RX 5700 XT (Mesa 22.0 w/ RADV) the framerate is much more stable, but slightly lower.
  - Issue: https://github.com/ValveSoftware/SteamVR-for-Linux/issues/230

- Head tracking feels sluggish/jittery/delayed/too smooth
  - This is related to the Linux kernel's hidraw driver and other factors.
  - The hidraw driver was improved in Linux 5.17 and newer. See: https://github.com/torvalds/linux/commit/8590222e4b021054a7167a4dd35b152a8ed7018e
  - The custom kernel provided with this repository includes the hidraw improvements and other necessary patches.

- Virtual controllers and hands render behind menus and 3D models appear "inverted"
  - No known workaround as of 2022-04-15, but this issue is not present in the SteamVR `linux_v1.14` Beta branch.
  - This might only affect AMD users (amdgpu + mesa)
  - Issue: https://github.com/ValveSoftware/SteamVR-for-Linux/issues/430

---

## Kernel Patches
- **[PATCH] drm/edid: Add Vive Pro 2 to non-desktop list**: https://lkml.org/lkml/2022/1/18/693
  - Diff: https://lkml.org/lkml/diff/2022/1/18/693/1
- **[PATCH v2] drm/edid: Support type 7 timings**: https://lkml.org/lkml/2022/1/23/302
  - Diff: https://lkml.org/lkml/diff/2022/1/23/302/1
- **[PATCH v2 1/2] drm/edid: parse DRM VESA dsc bpp target**: https://lkml.org/lkml/2022/2/20/151
  - Diff: https://lkml.org/lkml/diff/2022/2/20/151/1
- **[PATCH v2 2/2] drm/amd: use fixed dsc bits-per-pixel from edid**: https://lkml.org/lkml/2022/2/20/153
  - Diff: https://lkml.org/lkml/diff/2022/2/20/153/1
- **[PATCH 1/1] HID: hidraw: Replace hidraw device table mutex with a rwsem**: https://lkml.org/lkml/2021/11/30/545
  - Merged upstream: https://github.com/torvalds/linux/commit/8590222e4b021054a7167a4dd35b152a8ed7018e
  - Diff: https://lkml.org/lkml/diff/2021/11/30/545/1
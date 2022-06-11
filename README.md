# HTC VIVE Pro 2 on Linux and SteamVR 

This guide is meant for tinkerers who know their way around. \
I do not recommend attempting to use the VIVE Pro 2 on anything other than bleeding edge systems (such as Arch Linux) \
The VR experience on Linux as of 2022-06-12 is mediocre at best especially on the newer hardware such as the VIVE Pro 2. \
I can't recommend using SteamVR on Linux at the moment so consider this as experimentation rather than entertainment for now.

**Thanks for [CertainLach](https://github.com/CertainLach/VivePro2-Linux-Driver) for creating the driver for the VIVE Pro 2 on Linux!**

---

## WORK IN PROGRESS
**Updated**: 2022-06-12

See configuration info and driver status/progress here: https://github.com/CertainLach/VivePro2-Linux-Driver#progress

---

## Setup
**NOTE:** The custom kernel is only designed to be installed on Arch Linux. \
If you are on another distribution, will have to find out how to patch and compile a kernel on it. \
I personally do not recommend using anything else than a bleeding edge distro for this at the moment. \
See Kernel Patches section below for the patches used in this guide.

### Clone this repository
- `git clone https://github.com/santeri3700/vive-pro-2-on-linux.git`
- `cd ./vive-pro-2-on-linux`

### Build and install patched kernel
Kernel version: 5.18.3

#### Copy your current kernel config
**NOTE**: If you are currently running Linux version other than 5.18.x, you might have to update the config.
- `mkdir -p ~/.config/linux-vivepro2/`
- `zcat /proc/config.gz > ~/.config/linux-vivepro2/myconfig`

#### Optimize kernel timer frequency
This might improve performance if your default configuration is lower than 1000Hz. On Arch Linux, the default is usually 300Hz.
- Change "`CONFIG_HZ_1000 is not set`" to "`CONFIG_HZ_1000=y`"
- Change "`CONFIG_HZ=...`" to "`CONFIG_HZ=1000`"
- Disable all other "`CONFIG_HZ_*`" values by changing them to "`CONFIG_HZ_... is not set`"
- Example:
  ```
  # CONFIG_HZ_100 is not set
  # CONFIG_HZ_250 is not set
  # CONFIG_HZ_300 is not set
  CONFIG_HZ_1000=y
  CONFIG_HZ=1000
  ```

#### Build the custom kernel
- `export MAKEFLAGS="-j $(nproc)"`
- `env use_numa=n use_tracers=n makepkg -sc`

#### Install the custom kernel and update the bootloader (e.g. GRUB)
- `makepkg -si`
- `sudo grub-mkconfig -o /boot/grub/grub.cfg`
- `sudo grub-install`

### Install SteamVR
Install SteamVR from Steam and **close Steam after it has been installed**. \
[VIVE Console is no longer required](https://github.com/CertainLach/VivePro2-Linux-Driver/commit/70687011f80d58c78ee77868895def9d77adf262), but try installing it if you face issues without it.
- SteamVR:
  - [steam://install/250820](steam://install/250820)
  - https://store.steampowered.com/app/250820/
- VIVE Console for SteamVR (not necessary anymore):
  - [steam://install/1635730](steam://install/1635730) 
  - https://store.steampowered.com/app/1635730/

### Install VIVE Pro 2 Linux Driver by CertainLach
- GitHub repository: https://github.com/CertainLach/VivePro2-Linux-Driver
- CertainLach's Patreon: https://patreon.com/0lach

#### Install dependencies
- `sudo pacman -S git rsync rustup`
- `sudo pacman -S mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads`
- `sudo pacman -S wine` or `sudo pacman -S wine-staging`
  System Wine is used for the lens-server.

#### Install/Update nightly version of Rust for Windows x86_64 target
- `rustup +nightly-2022-04-08 target add x86_64-pc-windows-gnu`

#### Clone the driver repository
- `git clone https://github.com/CertainLach/VivePro2-Linux-Driver.git`
- `cd VivePro2-Linux-Driver`
- `export VIVEPRO2DRVDIR="$(pwd)"`

#### Clone and build the sewer tool repository
- `git clone https://github.com/CertainLach/sewer.git`
- `cd sewer`
- `cargo +nightly-2022-04-08 build --release --all-features --verbose`

#### Build driver-proxy
- `cd $VIVEPRO2DRVDIR/bin/driver-proxy`
- `cargo +nightly-2022-04-08 build --release --all-features --verbose`
  
#### Build lens-server
- `cd $VIVEPRO2DRVDIR/bin/lens-server`
- `cargo +nightly-2022-04-08 build --release --target x86_64-pc-windows-gnu --all-features --verbose`

#### Copy the compiled objects to the dist-proxy directory
- `cd $VIVEPRO2DRVDIR/dist-proxy/`
- `mkdir bin`
- `cp $VIVEPRO2DRVDIR/sewer/target/release/sewer ./bin`
- `cp $VIVEPRO2DRVDIR/target/x86_64-pc-windows-gnu/release/lens-server.exe ./lens-server/`
- `cp $VIVEPRO2DRVDIR/target/release/libdriver_proxy.so ./driver_lighthouse.so`

#### Run the install script to install the components
- `./install.sh`

### Check SteamVR files
```
$ cd $HOME/.local/share/Steam/steamapps/common/SteamVR

$ file drivers/lighthouse/bin/linux64/driver_lighthouse.so 
drivers/lighthouse/bin/linux64/driver_lighthouse.so: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, BuildID[sha1]=..., with debug_info, not stripped

$ file drivers/lighthouse/bin/linux64/driver_lighthouse_real.so
drivers/lighthouse/bin/linux64/driver_lighthouse_real.so: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, BuildID[sha1]=..., not stripped

$ file drivers/lighthouse/bin/linux64/lens-server/lens-server.exe 
drivers/lighthouse/bin/linux64/lens-server/lens-server.exe: PE32+ executable (console) x86-64, for MS Windows

$ file drivers/lighthouse/bin/linux64/lens-server/LibLensDistortion.dll
drivers/lighthouse/bin/linux64/lens-server/LibLensDistortion.dll: PE32+ executable (DLL) (GUI) x86-64, for MS Windows

$ file drivers/lighthouse/bin/linux64/lens-server/opencv_world346.dll
drivers/lighthouse/bin/linux64/lens-server/opencv_world346.dll: PE32+ executable (DLL) (console) x86-64, for MS Windows
```

---

## Playing in VR

### Connect the headset to your PC like shown in the official guide
You can check the output of `lsusb` and `sudo dmesg` to verify connectivity.

### Make sure Wine is properly installed system wide
- `wine64 --version`
- `wine64 winecfg`
  Try clearing the default wine prefix if you face issues with the lens-server (`mv ~/.wine ~/.wine_bak`)

### Add CAP_SYS_NICE capability for SteamVR compositor
This is done beforehand to avoid issues where Steam would require superuser access when launching SteamVR. \
It should also improve performance and latency. \
**WARNING! This enables SteamVR's "Asynchronous Reprojection" which is partially broken as of SteamVR version 1.23.1 (2022-06-03). See Workaround below**
- `cd ~/.steam/steam/steamapps/common/SteamVR/`
- `sudo setcap CAP_SYS_NICE=eip ./bin/linux64/vrcompositor-launcher`

### Launch Steam and start SteamVR
- Everything should work without additional setup.
- Complete the Room Setup like you would normally do.
- There are some issues in the current versions of SteamVR, check the Known issues and Troubleshooting sections for more information.

---

## Known issues & Workarounds
- Headset displays nothing and SteamVR fails to enable Direct Display Mode
  - This might be caused because of the missing kernel patches. The VIVE Pro 2 is not fully supported in the official releases of the Linux kernel as of 2022-06-12.
  - Wayland compatibility is a hit or miss (at least on SwayWM). Please open an issue if you have a workaround or tips regarding this.
  - Wayland related info and workaround(s): https://github.com/ValveSoftware/SteamVR-for-Linux/issues/499
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
  - Your kernel config's timer frequency might be set lower than 1000Hz which could affect the smoothness. See "Optimize kernel timer frequency" section.
  - The custom kernel provided with this repository includes the hidraw improvements and other necessary patches.

- Virtual controllers and hands render behind menus and 3D models appear "inverted"
  - No known workaround as of 2022-06-12, but this issue is not present in the SteamVR `linux_v1.14` Beta branch.
  - This might only affect AMD users (amdgpu + mesa)
  - Issue: https://github.com/ValveSoftware/SteamVR-for-Linux/issues/430

---

## Kernel Patches
- **[PATCH] drm/edid: Add Vive Pro 2 to non-desktop list**: https://lkml.org/lkml/2022/1/18/693
  - Diff: https://lkml.org/lkml/diff/2022/1/18/693/1
  - GitHub: https://github.com/CertainLach/VivePro2-Linux-Driver/blob/master/kernel-patches/0001-drm-edid-non-desktop.patch
- **[PATCH v2] drm/edid: Support type 7 timings** (merged to upstream in Linux 5.18): https://lkml.org/lkml/2022/1/23/302
  - Merged to upstream: https://github.com/torvalds/linux/commit/80ecb5d7c0f224218fdf956faec0ebe73d79f53d
  - Diff: https://lkml.org/lkml/diff/2022/1/23/302/1
  - GitHub: https://github.com/CertainLach/VivePro2-Linux-Driver/blob/master/kernel-patches/0002-drm-edid-type-7-timings.patch
- **[PATCH v2 1/2] drm/edid: parse DRM VESA dsc bpp target**: https://lkml.org/lkml/2022/2/20/151
  - Diff: https://lkml.org/lkml/diff/2022/2/20/151/1
  - GitHub: https://github.com/CertainLach/VivePro2-Linux-Driver/blob/master/kernel-patches/0003-drm-edid-dsc-bpp-parse.patch
- **[PATCH v2 2/2] drm/amd: use fixed dsc bits-per-pixel from edid**: https://lkml.org/lkml/2022/2/20/153
  - Diff: https://lkml.org/lkml/diff/2022/2/20/153/1
  - GitHub: https://github.com/CertainLach/VivePro2-Linux-Driver/blob/master/kernel-patches/0004-drm-amd-dsc-bpp-apply.patch
- **[PATCH 1/1] HID: hidraw: Replace hidraw device table mutex with a rwsem**: https://lkml.org/lkml/2021/11/30/545
  - Merged upstream: https://github.com/torvalds/linux/commit/8590222e4b021054a7167a4dd35b152a8ed7018e
  - Diff: https://lkml.org/lkml/diff/2021/11/30/545/1
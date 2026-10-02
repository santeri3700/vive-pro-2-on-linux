# VIVE Pro 2 with SteamVR on Linux

This guide will walk you through the process of setting up CertainLach's VIVE Pro 2 driver for SteamVR.

**Thanks to [CertainLach](https://github.com/CertainLach/VivePro2-Linux-Driver) for creating the kernel patches and a driver for the VIVE Pro 2 on Linux!**


## Install Steam and SteamVR
NOTE: Install the native versions of Steam and SteamVR. Do NOT use Proton to run these two.
1. Install Steam from the official package
   - `sudo pacman -S steam`
   - Do **NOT** use Snap, Flatpak or other sandboxed versions!
2. Install SteamVR from Steam and **fully close Steam after it has been installed**.
- SteamVR:
  - [steam://install/250820](steam://install/250820)
  - https://store.steampowered.com/app/250820/

Latest tested version of SteamVR are Stable 2.17.10 (Build ID 25330290) and Beta 2.18.2 (Build ID 25664061).

## Driver setup

### Install dependencies
- `sudo pacman -S git rsync rustup rsync`
- `sudo pacman -S mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads`
- `rustup toolchain install nightly-2026-10-02`

### Install/Update nightly version of Rust for Windows x86_64 target
- `rustup +nightly-2026-10-02 target add x86_64-pc-windows-gnu`

### Clone the driver repository
- `git clone https://github.com/CertainLach/VivePro2-Linux-Driver.git`
- `cd VivePro2-Linux-Driver`
- `export VIVEPRO2DRVDIR="$(pwd)"`

### Clone and build the sewer tool repository
- `git clone https://github.com/CertainLach/sewer.git`
- `cd sewer`
- `cargo +nightly-2026-10-02 build --release --all-features --verbose`

### Build driver-vivevr
- `cd $VIVEPRO2DRVDIR/bin/driver-vivevr`
- `cargo +nightly-2026-10-02 build --release --all-features --verbose`

### Copy the compiled objects to the dist directory
- `cd $VIVEPRO2DRVDIR/dist/`
- `mkdir tools`
- `cp $VIVEPRO2DRVDIR/sewer/target/release/sewer ./tools/sewer`
- `cp $VIVEPRO2DRVDIR/target/release/libdriver_vivevr.so ./bin/linux64/driver_viveVR.so`

### Run the install script to install the components and patch SteamVR Room Setup
- `./install.sh`

### Check SteamVR driver files and configuration
```
$ bash ~/.local/share/Steam/steamapps/common/SteamVR/bin/vrpathreg.sh
...
External Drivers:
        viveVR : /home/$USER/.local/share/vivepro2-linux-driver

$ cd ~/.local/share/vivepro2-linux-driver

$ cat driver.vrdrivermanifest
{
        "alwaysActivate": false,
        "name": "viveVR",
        "directory": "",
        "resourceOnly": false,
        "redirectsDisplay": true,
        "hmd_presence": ["0BB4.0342"]
}

$ file bin/linux64/driver_viveVR.so
bin/linux64/driver_viveVR.so: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, BuildID[sha1]=..., not stripped

$ file bin/linux64/lens-distort/LibLensDistortion.dll
bin/linux64/lens-distort/LibLensDistortion.dll: PE32+ executable for MS Windows 6.00 (DLL), x86-64, 8 sections

$ file bin/linux64/lens-distort/msvcp140.dll
bin/linux64/lens-distort/msvcp140.dll: PE32+ executable for MS Windows 6.00 (DLL), x86-64, 7 sections

$ file bin/linux64/lens-distort/opencv_world346.dll
bin/linux64/lens-distort/opencv_world346.dll: PE32+ executable for MS Windows 6.00 (DLL), x86-64, 11 sections

$ file bin/linux64/lens-distort/ucrtbase.dll
bin/linux64/lens-distort/ucrtbase.dll: PE32+ executable for MS Windows 5.02 (DLL), x86-64, 6 sections

$ file bin/linux64/lens-distort/vcruntime140.dll
bin/linux64/lens-distort/vcruntime140.dll: PE32+ executable for MS Windows 6.00 (DLL), x86-64, 7 sections
```

## Settings
The driver should create initial configuration during first start. You can then adjust the settings by editing the `steamvr.vrsettings` file. \
Settings such as the brightness, resolution and refresh rate must be changed from the file instead of SteamVR settings menu. \
**ATTENTION**: Resolutions higher than 2 require the kernel patches to work! Use resolution 1 for 120Hz without kernel patches.

Default config location: `~/.local/share/Steam/config/steamvr.vrsettings`

Example section:
```json
"vivepro2" : {
    "brightness" : 130,
    "noiseCancel" : false,
    "resolution" : 1
}
```
See [CertainLach's repository](https://github.com/CertainLach/VivePro2-Linux-Driver?tab=readme-ov-file#configuration) for more information about the settings and values.

---

## Running VR games

## Launch Steam
- Start SteamVR \
  **NOTE**: Add the launch options `QT_QPA_PLATFORM=xcb %command%` to SteamVR if the SteamVR main window fails to display correctly on Wayland sessions.
- Complete the Room Setup like you would normally do. You only need to do this once. \
  **NOTE**: The Room Setup is a buggy mess and might not work always. \
  See https://vronlinux.org/docs/steamvr/ for more information and workarounds.
- Play VR games (with Proton or another Wine/Proton fork unless you've managed to find a native Linux game)

# Troubleshooting
See [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

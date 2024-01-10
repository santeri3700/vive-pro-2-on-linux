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


## Driver setup

### Install dependencies
- `sudo pacman -S git rsync rustup`
- `sudo pacman -S mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads`
- `rustup toolchain install nightly`
- Optional: `sudo pacman -S wine` or `sudo pacman -S wine-staging`

  System WINE is not required but will be used as a fallback for the lens-server.exe if Proton is not available.

### Install/Update nightly version of Rust for Windows x86_64 target
- `rustup +nightly target add x86_64-pc-windows-gnu`

### Clone the driver repository
- `git clone https://github.com/CertainLach/VivePro2-Linux-Driver.git`
- `cd VivePro2-Linux-Driver`
- `export VIVEPRO2DRVDIR="$(pwd)"`

### Clone and build the sewer tool repository
- `git clone https://github.com/CertainLach/sewer.git`
- `cd sewer`
- `cargo +nightly build --release --all-features --verbose`

### Build driver-proxy
- `cd $VIVEPRO2DRVDIR/bin/driver-proxy`
- `cargo +nightly build --release --all-features --verbose`
  
### Build lens-server
- `cd $VIVEPRO2DRVDIR/bin/lens-server`
- `cargo +nightly build --release --target x86_64-pc-windows-gnu --all-features --verbose`

### Copy the compiled objects to the dist-proxy directory
- `cd $VIVEPRO2DRVDIR/dist-proxy/`
- `mkdir bin`
- `cp $VIVEPRO2DRVDIR/sewer/target/release/sewer ./bin`
- `cp $VIVEPRO2DRVDIR/target/x86_64-pc-windows-gnu/release/lens-server.exe ./lens-server/`
- `cp $VIVEPRO2DRVDIR/target/release/libdriver_proxy.so ./driver_lighthouse.so`

### Run the install script to install the components
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

## Running VR games

### Make sure Proton and/or WINE is installed
- Steam -> Tools -> Proton Experimental -> Install: Enabled
- Steam -> Settings -> Compatibility -> Enable Steam Play for supported titles: Enabled
- Steam -> Settings -> Compatibility -> Run other titles with: Proton Experimental
- Steam -> Settings -> Compatibility -> Enable Steam Play for all other titles

**OR**

- `wine64 --version`
- `wine64 winecfg`

TIP: Try clearing the default wine prefix if you face issues with system wine running the lens-server (`mv ~/.wine ~/.wine_bak`)

## Launch Steam and start SteamVR
- You might have to start SteamVR twice before it actually works.
- Complete the Room Setup like you would normally do.
- Play VR games

# Troubleshooting
See [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

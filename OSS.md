# VIVE Pro 2 with Monado, OpenComposite & libsurvive

# Setup
These open source components are work in progress and many things are broken or can break. \
Prefer SteamVR if you don't like to suffer. You've been warned.

## Common dependencies
Arch Linux: `sudo git make cmake ninja gcc ccache pkg-config` \
Ubuntu/Debian dependencies: `sudo git make cmake ninja-build gcc g++ ccache pkg-config`

## Preparing a work directory
The directory doesn't have to be persistent.
```
mkdir /tmp/vivepro2foss
cd /tmp/vivepro2foss
export VIVEPRO2OSSDIR=$(pwd)
```

## Installing libsurvive
Open source alternative for the Lighthouse Tracking System.

Arch Linux dependencies: `eigen` \
Ubuntu/Debian dependencies: `libeigen3-dev libusb-dev libusb-1.0-0-dev`

```
cd $VIVEPRO2OSSDIR
git clone https://github.com/cntools/libsurvive.git --recursive
cd libsurvive
cd $VIVEPRO2OSSDIR/libsurvive
cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -DUSE_HIDAPI=ON
ninja -C build
sudo ninja -C build install
sudo cp ./useful_files/81-vive.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo mkdir /etc/bash_completion.d
sudo cp survive_autocomplete.sh /etc/bash_completion.d/
```

## Installing Basalt for Monado
Monado fork of the Basalt library for improved tracking and motion accuracy.

Arch Linux dependencies: `tbb opencv fmt boost glew eigen` \
Ubuntu/Debian dependencies: `libtbb-dev opencv-dev libfmt-dev libboost-dev libboost-serialization-dev libboost-date-time-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev libbz2-dev liblz4-dev libglew-dev libeigen3-dev`

```
cd $VIVEPRO2OSSDIR
git clone --recursive https://gitlab.freedesktop.org/mateosss/basalt.git
cd basalt
cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DBASALT_BUILD_SHARED_LIBRARY_ONLY=ON -DCMAKE_BUILD_TYPE=Release
sed -i '1s/^/#include <stdint.h>\n/' thirdparty/Pangolin/include/pangolin/platform.h
ninja -C build
sudo ninja -C build install
```

## Building Monado
The open source OpenXR runtime. \
This must be compiled with vive and libsurvive support!
The VIVE Pro 2 will utilize the libsurvive library.

Arch Linux dependencies: `python eigen openxr openvr vulkan-headers vulkan-icd-loader sdl2 hidapi libgl glm wayland libcap libbsd libdrm libxml2 qt6-5compat icu` \
Ubuntu/Debian dependencies: `libeigen3-dev libopenxr-loader1 libopenxr-dev libopenvr-api1 libopenvr-dev libvulkan1 libvulkan-dev libsdl2-dev libsdl2-2.0-0 glslang-tools glslang-dev libglm-dev libwayland-dev libcap-dev libbsd-dev libdrm-dev libudev-dev libhidapi-dev libxml2 libxml2-dev libqt6core5compat6 libicu-dev libicu70`

```
cd $VIVEPRO2OSSDIR
git clone https://gitlab.freedesktop.org/monado/monado.git
cd monado
cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -DXRT_BUILD_DRIVER_VIVE=ON -DXRT_BUILD_DRIVER_SURVIVE=ON -DXRT_BUILD_DRIVER_OHMD=OFF
ninja -C build
sudo ninja -C build install
```

## Installing XR Hardware Rules
A set of udev rules to allow user access to XR devices.

```
cd $VIVEPRO2OSSDIR
git clone https://gitlab.freedesktop.org/monado/utilities/xr-hardware/
cd xr-hardware
sudo make install
sudo udevadm control --reload-rules && sudo udevadm trigger
```

## Optional: Installing Monado SteamVR plugin for OpenXR games
As of writing this guide, I have been unable to make SteamVR 1.14, 2.x and 2.x Beta branches to work with Monado. \
You may try to use the plugin but it probably won't work. Please open an issue if you get this working! \
In the meanwhile, use the proprietary SteamVR runtime if you need SteamVR and its tools.

Steam and SteamVR must be installed before installing the plugin! \
**NOTE**: OpenVR games will not work with just this. You need OpenComposite for OpenVR games.
```
~/.steam/steam/steamapps/common/SteamVR/bin/vrpathreg.sh adddriver /usr/share/steamvr-monado
~/.steam/steam/steamapps/common/SteamVR/bin/vrpathreg.sh | grep 'steamvr-monado'
```

## Installing OpenComposite (previously OpenOVR) for OpenVR & OpenXR games
This component will make it possible to play OpenVR and OpenXR games with Monado. \
It is required when playing OpenVR or OpenXR games via Proton or the Steam Linux Runtime.

**ATTENTION!** The OpenComposite library (vrclient.so) MUST be installed under your home directory if playing Steam games with Proton or the Steam Linux Runtime.

Arch Linux dependencies: `eigen openxr glm vulkan-icd-loader vulkan-headers` \
Ubuntu/Debian dependencies: `libeigen3-dev glslang-tools glslang-dev libglm-dev libopenxr-loader1 libopenxr-dev libvulkan1 libvulkan-dev`

```
cd $VIVEPRO2OSSDIR
git clone --recursive https://gitlab.com/znixian/OpenOVR
cd OpenOVR
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
ninja -C build
mkdir -p ~/.local/share/opencomposite/bin/linux64/
cp build/bin/linux64/vrclient.so ~/.local/share/opencomposite/bin/linux64/vrclient.so
```
### Configuring OpenComposite
Instructions based on: https://monado.freedesktop.org/valve-index-setup.html#5-setting-up-opencomposite
1. Open Steam and install SteamVR. This should initialize the OpenVR configs. \
   **NOTE**: You **MUST** have a non-sandboxed version of Steam installed. Snap, Flatpak and other sandboxed versions are **NOT** supported!
2. Rename the existing Steam OpenVR config: `mv ~/.config/openvr/openvrpaths.vrpath ~/.config/openvr/openvrpaths.vrpath.steamvr`
3. Create an OpenVR config for OpenComposite: `nano ~/.config/openvr/openvrpaths.vrpath.opencomp`
   
   The contents of the file should be this. Replace USERNAME with your actual username. Do **NOT** use "~/" or environment variables!
   ```json
   {
       "config": [
           "/home/user/.local/share/Steam/config"
       ],
       "external_drivers": null,
       "jsonid": "vrpathreg",
       "log": [
           "/home/USERNAME/.local/share/Steam/logs"
       ],
       "runtime": [
           "/home/USERNAME/.local/share/opencomposite/"
       ],
       "version": 1
   }
   ```
4. Make the OpenComposite config file read-only so Steam doesn't overwrite it.
   ```
   chmod 444 ~/.config/openvr/openvrpaths.vrpath.opencomp
   ```
5. Replace the main config file with a symlink.
   You may switch between SteamVR and OpenComposite by changing the symlink.
   
   **WARNING!** Non-VR Proton games WILL BREAK when OpenComposite is enabled. Switch to SteamVR when you wish to play non-VR games with Proton! \
   See: https://github.com/ValveSoftware/Proton/issues/6038#issuecomment-1590246971

# Switching between SteamVR and OpenComposite
You can use the [switch-openvr-runtime.sh](switch-openvr-runtime.sh) script for convenience. \
It will manage switching the OpenVR config symlink with your choice. \
Usage: `switch-openvr-runtime.sh [opencomposite|steamvr]`

Alternatively you can manage the symlink manually:
```
# Enable OpenComposite and disable SteamVR
ln -sf $HOME/.config/openvr/openvrpaths.vrpath.opencomp $HOME/.config/openvr/openvrpaths.vrpath

# Enable SteamVR and disable OpenComposite
ln -sf $HOME/.config/openvr/openvrpaths.vrpath.steamvr $HOME/.config/openvr/openvrpaths.vrpath
```

# Calibrating
Libsurvive needs to be calibrated before the tracking works. \
See more information about libsurvive calibration: https://monado.freedesktop.org/libsurvive.html

### Method 1: Calibrating while playing a game or demo (best end results)
**WARNING:** The tracking may be very inaccurate and jumpy at the beginning. This can be nauseating!

1. Power on and place the headset and controllers on the ground pointing towards the front base station. This will become your front facing direction.
2. Remove any existing libsurvive calibration configs: `mv ~/.config/libsurvive/config.json ~/.config/libsurvive/config.json.bak`
3. Start Monado with the libsurvive auto-calibration enabled (`SURVIVE_GLOBALSCENESOLVER=1`): `XRT_COMPOSITOR_SCALE_PERCENTAGE=140 XRT_COMPOSITOR_COMPUTE=1 SURVIVE_GLOBALSCENESOLVER=1 SURVIVE_TIMECODE_OFFSET_MS=-6.94 monado-service`
4. Wait for 1-2 minutes before touching the headset or controllers. This is for letting libsurvive to do some initial measurements on the ground.
5. Start a VR game and play it for about 5 minutes. Pick a game which needs a lot of head and hand movement (such as Beat Saber). \
   During this time libsurvive will take lots of measurements which improves tracking accuracy. \
   **WARNING**: The game might feel a bit twitchy and jumpy during the calibration. \
   Tracking accuracy seems to get really good at around the 750 measurements mark.
   ```
   Info: MPFIT success 6331870.198420/27395.5559000724/0.0006107 (743 measurements, 1, MP_OK_CHI, 32 iters, up err 0.0000553, trace 0.0002583)
   ```
6. Close the game and Monado (CTRL+C). Next time you start Monado, make sure the libsurvive auto-calibration is disabled (`SURVIVE_GLOBALSCENESOLVER=0`).
7. Create a backup of the libsurvive calibration config: `mv ~/.config/libsurvive/config.json ~/.config/libsurvive/config.json.calibrated`

### Method 2: Calibrating with survive-cli (headless)
1. Power on and place the headset and controllers on the ground pointing towards the front base station. This will become your front facing direction.
2. Remove libsurvive calibration: `mv ~/.config/libsurvive/config.json ~/.config/libsurvive/config.json.bak`
3. Start calibration: `survive-cli --requiredtrackersforcal T20 --allowalltrackersforcal 0`
4. Wait until the output says "MPFIT success ...".
5. Press CTRL+C twice to stop the calibration process.
6. Start the calibration again (same command as in step 2)
7. Wait until the output says "MPFIT success ... (XYZ measurements, ..." where XYZ is nearly or over 750. \
   You may have to wait a few minutes until the calibration reaches such measurement levels. \
   If you don't get near or over 750 measurements within 5 minutes, re-run steps 5, 3, 7 in mentioned order.
8. Press CTRL+C twice to stop the calibration process.

### Method 3: Calibrating with an existing SteamVR calibration
You need to set up SteamVR and do the calibration first. This can be done on Windows or on Linux with [CertainLach's proxy driver](STEAMVR.md). \
Don't forget to disable OpenComposite before launching SteamVR on Linux!

1. Remove existing libsurvive config.json
`mv ~/.config/libsurvive/config.json ~/.config/libsurvive/config.json.bak`
2. Calibrate with an existing lighthousedb.json file
`survive-cli --steamvr-calibration /path/to/lighthousedb.json`
3. Wait for 30s and press CTRL+C twice
4. Run the same calibration command (step 2) again
5. Wait for 30s and press CTRL+C twice again.

The lighthousedb.json can be found from the following locations:
- Windows: `C:\Program Files (x86)\Steam\config\lighthouse\lighthousedb.json`
- Linux: `~/.local/share/Steam/config/lighthouse/lighthousedb.json`

# Running VR games

## Testing Monado
- Run hello_xr: `XR_RUNTIME_JSON=/usr/share/openxr/1/openxr_monado.json hello_xr -g Vulkan` \
  You should see a floating blue square in front of you and your controllers should be tracked 3D blocks.

## Setting CAP_SYS_NICE capabilities for Monado Service
- This will not persist between reboots!
- `pkexec setcap CAP_SYS_NICE=eip /usr/bin/monado-service`

## Running OpenVR and OpenXR games with Monado (without SteamVR)
- Start Monado: `XRT_COMPOSITOR_SCALE_PERCENTAGE=140 XRT_COMPOSITOR_COMPUTE=1 SURVIVE_GLOBALSCENESOLVER=0 SURVIVE_TIMECODE_OFFSET_MS=-6.94 monado-service` \
  **NOTE**: Monado might get stuck on the first run. You should see "The Monado service has started." when Monado has successfully started. \
  Monado and libsurvive will prints some errors related to unknown data. These can be ignored for now.

- Steam game launch option: `XR_RUNTIME_JSON=/run/host/usr/share/openxr/1/openxr_monado.json PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%
` \
  NOTE: You **MUST** have a non-sandboxed version of Steam installed. Snap, Flatpak and other sandboxed versions are **NOT** supported!

- Non-Steam game: `XR_RUNTIME_JSON=/usr/share/openxr/1/openxr_monado.json /path/to/game`
- Godot game: `XR_RUNTIME_JSON=/usr/share/openxr/1/openxr_monado.json /path/to/game --rendering-driver vulkan --xr-mode on`

## Running OpenVR and OpenXR games with Monado (with SteamVR Monado plugin)
This doesn't seem to work at the time of writing this. \
Please open an issue if you manage to get SteamVR (with the overlay etc) running with Monado instead of [CertainLach's proxy driver](STEAMVR.md).

# Troubleshooting
See [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

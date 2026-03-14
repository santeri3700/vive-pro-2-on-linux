# Troubleshooting VIVE Pro 2 on Linux

### Common issues
- Snap, Flatpak and other sandboxed versions of Steam are not supported!

- Headset displays nothing and/or Direct Display Mode does not work
  - This might be caused because of an old kernel version or missing kernel patches. The VIVE Pro 2 should work with Linux kernel 6.4+ without patches but with lower resolutions (0-2).
  - With older kernels, you might have to set the HMD output as 'non-desktop' on X11: `xrandr --output DP-x --set non-desktop 1`
  - You might be using an incompatible desktop environment or compositor (DRM leasing support is required).
    - See compatibility list here: https://help.steampowered.com/en/faqs/view/18A4-1E10-8A94-3DDA

- A key component of SteamVR isn't working properly
  - This could be an issue with the lens-server / Lens distortion helper.
  - Just try restarting whole Steam and try again. Sometimes it takes a couple of tries to get it working.

- Headset only displays gargabe and glitchy colors
  - Make sure all of the cables are properly connected. Unplug and replug everything to be sure.
  - You might be using an unpatched kernel with high resolution setting (3-5). Try lowering the resolution to 0-2 or patch the kernel to be able to use higher resolutions.
  - See LKML for more information about the patches: https://lore.kernel.org/all/20251202110218.9212-1-iam@lach.pw/

- Headset displays everything upside down
  - The lens-server / Lens distortion helper probably didn't start correctly.
  - Make sure SteamVR and Proton are both installed onto the same drive (if using Proton).
  - Try manually pointing to Proton's wine binary by using the launch option `WINE=$HOME/'.local/share/Steam/steamapps/common/Proton - Experimental/files/bin/wine'`
  - Try using system WINE by using the launch option `WINE=/usr/bin/wine %command%` for SteamVR.

- OpenXR games don't work with Proton / OpenXR games don't connect launch onto the VR headset
  - Some OpenXR games (such as Beat Saber) fail to launch without specifying the `XR_RUNTIME_JSON` environment variable.
    
    Here are a couple examples (replace USERNAME with your actual username)

    SteamVR OpenXR launch options: `XR_RUNTIME_JSON=/home/USERNAME/.local/share/Steam/steamapps/common/SteamVR/steamxr_linux64.json %command%`

    Monado OpenXR launch options: `XR_RUNTIME_JSON=/usr/share/openxr/1/openxr_monado.json %command%`

- The menu button doesn't work (on some games)
  - I suspect this is an OpenXR issue. I haven't found a fix or a workaround. Please open an issue if you do. \
    Steam discussion related to Beat Saber: https://steamcommunity.com/app/620980/discussions/2/6821308966017816627/

### SteamVR specific issues
- See: https://github.com/ValveSoftware/SteamVR-for-Linux/

### FOSS specific issues
- Re-centering does not seem to be supported at the moment.
- See: https://gitlab.freedesktop.org/monado/monado/-/issues

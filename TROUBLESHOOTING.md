# Troubleshooting VIVE Pro 2 on Linux

### Common issues
- Snap, Flatpak and other sandboxed versions of Steam are not supported!

- Headset displays nothing and/or Direct Display Mode does not work
  - This might be caused because of the missing kernel patches. The VIVE Pro 2 is not fully supported in the official releases of the Linux kernel as of 2024-01-10.
  - You might have to set the HMD output as 'non-desktop' on X11: `xrandr --output DP-x --set non-desktop 1`
  - You might be using an incompatible desktop environment or compositor (DRM leasing support is required).
    - See compatibility list here: https://help.steampowered.com/en/faqs/view/18A4-1E10-8A94-3DDA

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

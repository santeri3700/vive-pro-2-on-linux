# HTC VIVE Pro 2 on Linux 

This guide is meant for tinkerers who know their way around.

I do not recommend attempting to use the VIVE Pro 2 on anything other than bleeding edge systems (such as Arch Linux which is the main focus of this repository).

The VR experience on Linux as of 2024-01-10 is decent when you can get SteamVR 2.0+ working.

**Thanks to [CertainLach](https://github.com/CertainLach/VivePro2-Linux-Driver) for creating the kernel patches and a driver for the VIVE Pro 2 on Linux!**

Also see these helpful sources:
- Linux VR Adventures Wiki: https://lvra.gitlab.io/
- VR on Linux: https://vronlinux.org/
- SteamVR for Linux Support: https://help.steampowered.com/en/faqs/view/18A4-1E10-8A94-3DDA
- Reddit: https://www.reddit.com/r/virtualreality_linux/

---

## WORK IN PROGRESS
**Updated**: 2024-01-10

## Setup

### Build and install the patched kernel
- `cd kernel`
- Follow [KERNEL.md](KERNEL.md)

### Install PolKit rule to allow setting CAP_SYS_NICE capabilities for the SteamVR compositor and/or Monado service without sudo

**NOTE**: This rule assumes the following installation locations for SteamVR and Monado:
- SteamVR: `/home/$USER/.steam/steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher`
- SteamVR: `/home/$USER/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher`
- Monado: `/usr/bin/monado-service`

Modify the rule if your home or SteamVR directory is elsewhere (which is unsupported by Steam as far as I know).

#### Install PolKit rule
`sudo cp ./polkit-vr-setcap-nice.rules /etc/polkit-1/rules.d/90-vr-setcap-nice.rules`

#### Restart polkit.service and test the rules
You should not be prompted for password when running the pkexec commands. \
We will assume you have both SteamVR and Monado installed (not both are required however).
- `sudo systemctl restart polkit.service`
- `pkexec setcap CAP_SYS_NICE=eip /home/$USER/.steam/steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher`
- `pkexec setcap CAP_SYS_NICE=eip /usr/bin/monado-service`

### Install SteamVR and the VIVE Pro 2 Linux Driver by CertainLach
- CertainLach's repository: https://github.com/CertainLach/VivePro2-Linux-Driver
- CertainLach's Patreon: https://patreon.com/0lach
- Instructions: [STEAMVR.md](STEAMVR.md)

### EXPERIMENTAL: VR with open source software
- This is an open source alternative to the regular SteamVR and CertainLach's driver.
- Instructions: [OSS.md](OSS.md)

## Playing VR games
- See SteamVR instructions: [STEAMVR.md](STEAMVR.md)
- See experimental OSS instructions: [OSS.md](OSS.md)

## Troubleshooting
See: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

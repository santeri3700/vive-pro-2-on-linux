#!/bin/bash

function switch-openvr-runtime() {
    # Get current runtime
    current_runtime_target=$(readlink -f $HOME/.config/openvr/openvrpaths.vrpath)
    if [[ "$current_runtime_target" == *opencomp* ]]; then
        current_runtime="OpenComposite"
    elif [[ "$current_runtime_target" == *steamvr* ]]; then
        current_runtime="SteamVR"
    else
        current_runtime="Default (SteamVR?)"
    fi

    # Help
    if [ -z "$1" ] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        echo "Usage: switch-openvr-runtime.sh [RUNTIME]"
        echo "Runtimes:"
        echo "- steamvr: Enable SteamVR OpenVR runtime"
        echo "- opencomposite: Enable OpenComposite OpenVR translation layer"
        echo "Currently enabled: $current_runtime"
        return 1
    fi

    # Switching
    if [[ "$1" == "steam" ]] || [[ "$1" == "steamvr" ]]; then
        echo "Switching OpenVR runtime to SteamVR..."
        ln -sf $HOME/.config/openvr/openvrpaths.vrpath.steamvr $HOME/.config/openvr/openvrpaths.vrpath
        _result=$?
        if [ $_result -eq 0 ]; then
            echo "Now using SteamVR!"
            return 0
        else
            echo "Failed to switch! Ensure SteamVR config exists."
            return 1
        fi
    elif [[ "$1" == "opencomp" ]] || [[ "$1" == "opencomposite" ]]; then
        echo "Switching OpenVR runtime to OpenComposite..."
        ln -sf $HOME/.config/openvr/openvrpaths.vrpath.opencomp $HOME/.config/openvr/openvrpaths.vrpath
        chmod 444 $HOME/.config/openvr/openvrpaths.vrpath.opencomp
        _result=$?
        if [ $_result -eq 0 ]; then
            echo "Now using OpenComposite!"
            return 0
        else
            echo "Failed to switch! Ensure OpenComposite config exists."
            return 1
        fi
    else
        echo "Invalid runtime value \"\". See \"switch-openvr-runtime.sh --help\"."
        return 1
    fi
}

switch-openvr-runtime "$*"


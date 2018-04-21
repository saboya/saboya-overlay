#!/usr/bin/env bash

function ask {
    echo "$1"
    if [ -z "$assume" ]; then
        read continue
    else
        continue=$assume
        echo "$continue"
    fi
}

if [ -z "$WINEPREFIX" ]; then
    ask "WINEPREFIX is not set, continue? (y/N)"
    if [ "$continue" != "y" ] && [ "$continue" != "Y" ]; then
    exit 1
    fi
else
    if ! [ -f "$WINEPREFIX/system.reg" ]; then
        ask "WINEPREFIX does not point to an existing wine installation. Proceeding will create a new one, continue? (y/N)"
        if [ "$continue" != "y" ] && [ "$continue" != "Y" ]; then
        exit 1
        fi
    fi
fi

if [ -d "__amd64__" ]; then
	cd __amd64__
	sh __amd64__/setup_dxvk.sh -y
fi

if [ -d "__x86__" ]; then
	cd __x86__
	sh __x86__/setup_dxvk.sh -y
fi

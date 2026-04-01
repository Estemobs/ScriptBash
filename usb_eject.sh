#!/bin/bash

# Éjection automatique des périphériques USB en toute sécurité
for device in /dev/sd*1; do
    if [ -b "$device" ]; then
        umount "$device" && echo "Périphérique $device éjecté en toute sécurité"
    fi
done

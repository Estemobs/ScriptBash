#!/bin/bash

# Vérification des connexions SSH actives
SSHSessions=$(who | grep -c 'pts' || true)

if [ "$SSHSessions" -gt 0 ]; then
    echo "Attention: $SSHSessions connexions SSH actives"
else
    echo "Aucune connexion SSH active."
fi

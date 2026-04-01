#!/bin/bash

# Vérification des mises à jour de drivers matériels
if command -v ubuntu-drivers &> /dev/null; then
    if ubuntu-drivers devices | grep -q recommended; then
        echo "Des mises à jour de drivers matériels sont disponibles"
    else
        echo "Aucune mise à jour de driver recommandée trouvée."
    fi
else
    echo "ubuntu-drivers non disponible sur ce système."
fi

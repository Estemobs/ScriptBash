#!/bin/bash

# Fonction pour obtenir l'utilisation moyenne des ressources
rapport_utilisation() {
    echo "Rapport d'utilisation des ressources:"
    if command -v mpstat &> /dev/null; then
        echo "CPU: $(mpstat | awk '$3 ~ /[0-9.]+/ { print 100 - $13 }')%"
    else
        echo "CPU: mpstat non disponible"
    fi
    echo "Mémoire: $(free | grep Mem | awk '{print $3/$2 * 100.0}')%"
}

# Générer le rapport à la fin de la session
trap rapport_utilisation EXIT

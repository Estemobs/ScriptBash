#!/bin/bash

# Configurer les seuils
SEUIL_DISQUE=${SEUIL_DISQUE:-90}

# Vérification de l'utilisation du disque
UTILISATION_DISQUE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
if [ "$UTILISATION_DISQUE" -gt "$SEUIL_DISQUE" ]; then
    echo "Attention: utilisation du disque élevée ($UTILISATION_DISQUE%)"
fi

# Suivre les logs système en temps réel et filtrer les erreurs (boucle bloquante)
if [ -f /var/log/syslog ]; then
    tail -f /var/log/syslog | while read -r LOGLINE
    do
        if [[ "${LOGLINE,,}" == *"error"* ]]; then
            echo "Erreur détectée: ${LOGLINE}"
        fi
    done
else
    echo "Fichier de log /var/log/syslog introuvable."
fi

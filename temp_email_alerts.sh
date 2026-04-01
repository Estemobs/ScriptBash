#!/bin/bash

# Configuration des seuils de température (en degrés Celsius)
SEUIL_CPU=${SEUIL_CPU:-70}
SEUIL_GPU=${SEUIL_GPU:-70}
EMAIL=${EMAIL:-"votre.email@exemple.com"}

# Obtenir la température du CPU
TEMP_CPU=$(sensors 2>/dev/null | grep 'Core 0' | awk '{print $3}' | sed 's/+//g' | sed 's/°C//g' | head -1)

# Obtenir la température du GPU
TEMP_GPU=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)

# Vérifier si les températures dépassent les seuils
if [ -n "$TEMP_CPU" ] && [ "$TEMP_CPU" -gt "$SEUIL_CPU" ] 2>/dev/null; then
    echo "Attention: température du CPU élevée ($TEMP_CPU°C)"
    echo "Alerte température CPU élevée: $TEMP_CPU°C" | mail -s "Alerte Système" "$EMAIL"
fi

if [ -n "$TEMP_GPU" ] && [ "$TEMP_GPU" -gt "$SEUIL_GPU" ] 2>/dev/null; then
    echo "Attention: température du GPU élevée ($TEMP_GPU°C)"
    echo "Alerte température GPU élevée: $TEMP_GPU°C" | mail -s "Alerte Système" "$EMAIL"
fi

# Suivre les logs système en temps réel et envoyer des alertes par email si erreur détectée (boucle bloquante)
if [ -f /var/log/syslog ]; then
    tail -f /var/log/syslog | while read -r LOGLINE
    do
        if [[ "${LOGLINE,,}" == *"error"* ]]; then
            echo "Erreur critique détectée: ${LOGLINE}" | mail -s "Alerte Système" "$EMAIL"
        fi
    done
else
    echo "Fichier de log /var/log/syslog introuvable."
fi

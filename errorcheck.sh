#!/bin/bash

# Fichier de log à surveiller
LOG_FILE="/var/log/syslog"
ERROR_LOG="/tmp/system_error_check.log"

# Chercher des erreurs dans les logs
echo "Vérification des erreurs système..." > "$ERROR_LOG"
grep -i "error\|fail\|critical\|warning" "$LOG_FILE" >> "$ERROR_LOG"

# Si des erreurs sont trouvées, afficher un message dans le terminal
if [ -s "$ERROR_LOG" ]; then
    echo "Erreurs Système Détectées : Vérifie $ERROR_LOG pour plus de détails."
else
    echo "Système OK : Aucune erreur détectée."
fi

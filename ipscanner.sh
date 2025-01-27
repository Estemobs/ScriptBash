#!/bin/bash

# Détection automatique de l'adresse IP locale et du réseau
local_ip=$(hostname -I | awk '{print $1}')
if [[ -z "$local_ip" ]]; then
    echo "Impossible de détecter l'adresse IP locale."
    exit 1
fi

# Extraction du préfixe du réseau à partir de l'adresse IP locale
network_prefix=$(echo $local_ip | cut -d '.' -f 1-3)

# Génération du réseau local à scanner (ex: 192.168.1.0/24)
network="${network_prefix}.0/24"

# Affichage du réseau détecté
echo "Scan en cours sur le réseau local : $network..."

# Lancer un scan Nmap pour détecter les hôtes actifs et leurs informations
scan_results=$(nmap -sP --open --max-retries 2 --host-timeout 60s $network)

# Préparer un tableau temporaire pour les résultats
output_file=$(mktemp)

# Ajouter l'en-tête au tableau
printf "Nom de l'hôte\tAdresse IP\tAdresse MAC\tFabricant\n" >> "$output_file"


# Traitement des résultats pour extraire les informations nécessaires
echo "$scan_results" | grep -E "Nmap scan report for|MAC Address" | while read -r line; do
    if [[ "$line" =~ Nmap\ scan\ report\ for\ (.*) ]]; then
        ip="${BASH_REMATCH[1]}"
        name=$(echo "$ip" | awk '{print $1}') # Nom de l'hôte ou IP
    fi
    if [[ "$line" =~ MAC\ Address:\ ([0-9A-Fa-f:]+)\ \((.*)\) ]]; then
        mac="${BASH_REMATCH[1]}"
        manufacturer="${BASH_REMATCH[2]}"
        printf "%s\t%s\t%s\t%s\n" "$name" "$ip" "$mac" "$manufacturer" >> "$output_file"
    fi
done

# Afficher le tableau final avec un alignement propre
column -t -s $'\t' "$output_file"
rm "$output_file"  # Nettoyer le fichier temporaire

echo "Scan terminé."

#!/bin/bash

# Enable strict error handling
set -e  # Le script s arrête dès qu'une commande échoue

# Log file path
LOG_FILE="/var/log/update_all.log"

# Log function to capture the output
log() {
    echo "$(date) - $1" | tee -a $LOG_FILE
}

log "Début du processus de mise à jour de tous les paquets..."

# Mise à jour des paquets APT (paquets Debian)
log "Mise à jour des paquets APT..."
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
sudo apt autoremove -y  # Supprimer les paquets inutiles
log "Mise à jour des paquets APT terminée."

# Mise à jour des paquets Snap
log "Mise à jour des paquets Snap..."
sudo snap refresh
log "Mise à jour des paquets Snap terminée."

# Mise à jour des paquets Flatpak
log "Mise à jour des paquets Flatpak..."
flatpak update -y
log "Mise à jour des paquets Flatpak terminée."

# Mise à jour des paquets AppImage
log "Mise à jour des AppImages..."
# Si appimageupdate est installé, nous pouvons l'utiliser pour mettre à jour les AppImages.
# Sinon, il faudra les mettre à jour manuellement.
if command -v appimageupdate &> /dev/null; then
    if [ -d "$HOME/AppImages" ]; then
        for appimage in $HOME/AppImages/*.AppImage; do
            if [ -f "$appimage" ]; then
                log "Mise à jour de l'AppImage : $appimage"
                appimageupdate "$appimage"  # Utilisation de appimageupdate
            fi
        done
    else
        log "Aucune AppImage à mettre à jour dans $HOME/AppImages."
    fi
else
    log "appimageupdate non trouvé, mises à jour manuelles requises pour les AppImages."
fi

# Mise à jour des paquets .deb installés manuellement
log "Vérification des paquets .deb installés..."
for deb in ~/Downloads/*.deb; do
    if [ -f "$deb" ]; then
        log "Mise à jour du paquet .deb : $deb"
        sudo dpkg -i "$deb"  # Installer le fichier .deb
        sudo apt install -f -y  # Résoudre les dépendances manquantes après l'installation
    fi
done

# Mise à jour des logiciels installés à partir de .tar.gz
log "Vérification des logiciels installés à partir de .tar.gz..."
if [ -d "$HOME/logiciel_compilé" ]; then
    log "Mise à jour de logiciel compilé à partir de .tar.gz..."
    cd "$HOME/logiciel_compilé" && ./configure && make && sudo make install
else
    log "Aucun logiciel compilé trouvé dans le répertoire spécifié."
fi

log "Mise à jour terminée pour tous les paquets."

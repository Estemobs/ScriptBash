#!/bin/bash

# Répertoire de sauvegarde dans le home de l'utilisateur exécutant le script
USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
BACKUP_DIR="$USER_HOME/backup_$(date +%Y-%m-%d_%H-%M-%S)"
LOG_FILE="$BACKUP_DIR/backup.log"
mkdir -p "$BACKUP_DIR"

# Log function to capture the output
log() {
    echo "$(date) - $1" | tee -a "$LOG_FILE"
}

# Demander à l'utilisateur s'il veut vider les corbeilles
read -p "Voulez-vous vider toutes les corbeilles avant de commencer la sauvegarde ? (oui/non) " response
if [[ "$response" == "oui" ]]; then
    log "Vidage des corbeilles..."
    rm -rf $USER_HOME/.local/share/Trash/* && log "Corbeille de $USER_HOME vidée."
    sudo rm -rf /root/.local/share/Trash/* && log "Corbeille de root vidée."
else
    log "Les corbeilles ne seront pas vidées."
fi

# Sauvegarde des paquets installés
log "Sauvegarde des paquets..."
comm -23 <(apt-mark showmanual | sort) <(zcat /usr/share/doc/ubuntu-minimal/ubuntu-minimal.list.gz | sort) > "$BACKUP_DIR/apt-packages.txt" && log "Sauvegarde des paquets APT réussie."
flatpak list --app --columns=application > "$BACKUP_DIR/flatpak-apps.txt" && log "Sauvegarde des paquets Flatpak réussie."
snap list > "$BACKUP_DIR/snap-packages.txt" && log "Sauvegarde des paquets Snap réussie."

if command -v pip &> /dev/null; then
    pip freeze > "$BACKUP_DIR/pip-packages.txt" && log "Sauvegarde des paquets pip réussie."
else
    echo "pip non installé" > "$BACKUP_DIR/pip-packages.txt" && log "pip non installé."
fi

if command -v npm &> /dev/null; then
    npm list -g --depth=0 > "$BACKUP_DIR/npm-packages.txt" && log "Sauvegarde des paquets npm réussie."
else
    echo "npm non installé" > "$BACKUP_DIR/npm-packages.txt" && log "npm non installé."
fi

# Sauvegarde des configurations et fichiers importants
log "Sauvegarde des configurations..."
[ -d "$USER_HOME/.config" ] && cp -r "$USER_HOME/.config" "$BACKUP_DIR/config" && log "Sauvegarde de .config réussie."
[ -f "$USER_HOME/.bashrc" ] && cp "$USER_HOME/.bashrc" "$BACKUP_DIR/.bashrc" && log "Sauvegarde de .bashrc réussie."
[ -f "/root/.bashrc" ] && cp "/root/.bashrc" "$BACKUP_DIR/root.bashrc" && log "Sauvegarde de root.bashrc réussie."
[ -d "$USER_HOME/.gnupg" ] && cp -r "$USER_HOME/.gnupg" "$BACKUP_DIR/.gnupg" && log "Sauvegarde de .gnupg réussie."
[ -d "$USER_HOME/.ssh" ] && cp -r "$USER_HOME/.ssh" "$BACKUP_DIR/ssh" && log "Sauvegarde de .ssh réussie."

# Sauvegarde des extensions et paramètres GNOME
log "Sauvegarde des extensions et paramètres GNOME..."
[ -d "$USER_HOME/.local/share/gnome-shell/extensions/" ] && cp -r "$USER_HOME/.local/share/gnome-shell/extensions/" "$BACKUP_DIR/gnome-shell-extensions/" && log "Sauvegarde des extensions GNOME réussie."
dconf dump /org/gnome/ > "$BACKUP_DIR/gnome-settings.dconf" && log "Sauvegarde des paramètres GNOME réussie."

# Sauvegarde des thèmes et icônes
log "Sauvegarde des thèmes et icônes..."
[ -d "$USER_HOME/.themes" ] && cp -r "$USER_HOME/.themes" "$BACKUP_DIR/themes/" && log "Sauvegarde des thèmes réussie."
[ -d "$USER_HOME/.icons" ] && cp -r "$USER_HOME/.icons" "$BACKUP_DIR/icons/" && log "Sauvegarde des icônes réussie."

# Sauvegarde des fichiers personnels importants
log "Sauvegarde des fichiers personnels..."
rsync -av --exclude='.*' --exclude='ScriptBash' --exclude='backup_*' --exclude='Games' /home/* "$BACKUP_DIR/home/" && log "Sauvegarde des fichiers personnels réussie."

# Sauvegarde des crontabs
log "Sauvegarde des crontabs..."
crontab -l > "$BACKUP_DIR/crontab.txt" && log "Sauvegarde de crontab réussie."
sudo crontab -l > "$BACKUP_DIR/sudo-crontab.txt" && log "Sauvegarde de sudo crontab réussie."

# Création de l'archive ZIP
log "Création de l'archive ZIP..."
cd "$USER_HOME"
zip -r "$(basename $BACKUP_DIR).zip" "$(basename $BACKUP_DIR)" && log "Création de l'archive ZIP réussie."

# Nettoyage
log "Nettoyage des fichiers temporaires..."
rm -rf "$BACKUP_DIR" && log "Nettoyage des fichiers temporaires réussi."

log "Sauvegarde terminée ! L'archive se trouve dans : $USER_HOME/$(basename $BACKUP_DIR).zip"

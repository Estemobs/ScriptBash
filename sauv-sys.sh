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

# Sauvegarde des paquets installés
log "Sauvegarde des paquets..."
dpkg --get-selections > "$BACKUP_DIR/apt-packages.txt" && log "Sauvegarde des paquets APT réussie."
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
[ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$BACKUP_DIR/config" && log "Sauvegarde de .config réussie."
[ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc" && log "Sauvegarde de .bashrc réussie."
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc" && log "Sauvegarde de .zshrc réussie."
[ -d "$HOME/.local/share" ] && cp -r "$HOME/.local/share" "$BACKUP_DIR/.local_share" && log "Sauvegarde de .local/share réussie."
[ -d "$HOME/.gnupg" ] && cp -r "$HOME/.gnupg" "$BACKUP_DIR/.gnupg" && log "Sauvegarde de .gnupg réussie."
[ -d "$HOME/.ssh" ] && cp -r "$HOME/.ssh" "$BACKUP_DIR/ssh" && log "Sauvegarde de .ssh réussie."

# Sauvegarde des extensions et paramètres GNOME
log "Sauvegarde des extensions et paramètres GNOME..."
[ -d "$HOME/.local/share/gnome-shell/extensions/" ] && cp -r "$HOME/.local/share/gnome-shell/extensions/" "$BACKUP_DIR/gnome-shell-extensions/" && log "Sauvegarde des extensions GNOME réussie."
dconf dump /org/gnome/ > "$BACKUP_DIR/gnome-settings.dconf" && log "Sauvegarde des paramètres GNOME réussie."

# Sauvegarde des thèmes et icônes
log "Sauvegarde des thèmes et icônes..."
[ -d "$HOME/.themes" ] && cp -r "$HOME/.themes" "$BACKUP_DIR/themes/" && log "Sauvegarde des thèmes réussie."
[ -d "$HOME/.icons" ] && cp -r "$HOME/.icons" "$BACKUP_DIR/icons/" && log "Sauvegarde des icônes réussie."

# Sauvegarde des scripts et applications
log "Sauvegarde des scripts et applications..."
[ -d "$HOME/bin" ] && cp -r "$HOME/bin" "$BACKUP_DIR/bin/" && log "Sauvegarde de bin réussie."
[ -d "$HOME/scripts" ] && cp -r "$HOME/scripts" "$BACKUP_DIR/scripts/" && log "Sauvegarde de scripts réussie."

# Sauvegarde des fichiers personnels importants
log "Sauvegarde des fichiers personnels..."
[ -d "$HOME/Documents" ] && cp -r "$HOME/Documents" "$BACKUP_DIR/Documents/" && log "Sauvegarde de Documents réussie."
[ -d "$HOME/Images" ] && cp -r "$HOME/Images" "$BACKUP_DIR/Images/" && log "Sauvegarde de Images réussie."

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

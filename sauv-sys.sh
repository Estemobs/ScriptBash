#!/bin/bash

# Répertoire de sauvegarde
BACKUP_DIR="$HOME/backup_$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p "$BACKUP_DIR"

# Sauvegarde des paquets installés
echo "Sauvegarde des paquets..."
dpkg --get-selections > "$BACKUP_DIR/apt-packages.txt"
flatpak list --app --columns=application > "$BACKUP_DIR/flatpak-apps.txt"
snap list > "$BACKUP_DIR/snap-packages.txt"

if command -v pip &> /dev/null; then
    pip freeze > "$BACKUP_DIR/pip-packages.txt"
else
    echo "pip non installé" > "$BACKUP_DIR/pip-packages.txt"
fi

if command -v npm &> /dev/null; then
    npm list -g --depth=0 > "$BACKUP_DIR/npm-packages.txt"
else
    echo "npm non installé" > "$BACKUP_DIR/npm-packages.txt"
fi

# Sauvegarde des configurations et fichiers importants
echo "Sauvegarde des configurations..."
[ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$BACKUP_DIR/config"
[ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc"
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
[ -d "$HOME/.local/share" ] && cp -r "$HOME/.local/share" "$BACKUP_DIR/.local_share"
[ -d "$HOME/.gnupg" ] && cp -r "$HOME/.gnupg" "$BACKUP_DIR/.gnupg"
[ -d "$HOME/.ssh" ] && cp -r "$HOME/.ssh" "$BACKUP_DIR/ssh"

# Sauvegarde des extensions et paramètres GNOME
echo "Sauvegarde des extensions et paramètres GNOME..."
[ -d "$HOME/.local/share/gnome-shell/extensions/" ] && cp -r "$HOME/.local/share/gnome-shell/extensions/" "$BACKUP_DIR/gnome-shell-extensions/"
dconf dump /org/gnome/ > "$BACKUP_DIR/gnome-settings.dconf"

# Sauvegarde des thèmes et icônes
echo "Sauvegarde des thèmes et icônes..."
[ -d "$HOME/.themes" ] && cp -r "$HOME/.themes" "$BACKUP_DIR/themes/"
[ -d "$HOME/.icons" ] && cp -r "$HOME/.icons" "$BACKUP_DIR/icons/"

# Sauvegarde des scripts et applications
echo "Sauvegarde des scripts et applications..."
[ -d "$HOME/bin" ] && cp -r "$HOME/bin" "$BACKUP_DIR/bin/"
[ -d "$HOME/scripts" ] && cp -r "$HOME/scripts" "$BACKUP_DIR/scripts/"

# Sauvegarde des fichiers personnels importants
echo "Sauvegarde des fichiers personnels..."
[ -d "$HOME/Documents" ] && cp -r "$HOME/Documents" "$BACKUP_DIR/Documents/"
[ -d "$HOME/Images" ] && cp -r "$HOME/Images" "$BACKUP_DIR/Images/"

# Sauvegarde des crontabs
echo "Sauvegarde des crontabs..."
crontab -l > "$BACKUP_DIR/crontab.txt"
sudo crontab -l > "$BACKUP_DIR/sudo-crontab.txt"

# Création de l'archive ZIP
echo "Création de l'archive ZIP..."
cd "$HOME"
zip -r "$BACKUP_DIR.zip" "$BACKUP_DIR"

# Nettoyage
echo "Nettoyage des fichiers temporaires..."
rm -rf "$BACKUP_DIR"

echo "Sauvegarde terminée ! L'archive se trouve dans : $HOME/$BACKUP_DIR.zip"

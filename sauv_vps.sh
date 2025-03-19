#!/bin/bash

set -e  # Arrêter le script en cas d'erreur
set -x  # Activer le mode debug

# Détection automatique du disque contenant l'OS
SOURCE_DISK=$(lsblk -o NAME,MOUNTPOINT | grep ' /$' | awk '{print "/dev/" $1}')
echo "Disque détecté : $SOURCE_DISK"

# Détection automatique du répertoire de sauvegarde
BACKUP_DIR="$HOME/backup"
mkdir -p "$BACKUP_DIR"
echo "Répertoire de sauvegarde : $BACKUP_DIR"

# Générer un nom de fichier avec timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
IMAGE_NAME="backup_$TIMESTAMP.img"
IMAGE_PATH="$BACKUP_DIR/$IMAGE_NAME"
COMPRESSED_IMAGE="$IMAGE_PATH.gz"

# Vérification des dépendances
for cmd in partclone gzip; do
    if ! command -v $cmd &>/dev/null; then
        echo " Commande $cmd introuvable. Installation..."
        sudo apt install -y $cmd
    fi
done

# 1. Création de l'image disque avec Partclone
echo "Création de l'image du disque..."
sudo partclone.ext4 -c -s "$SOURCE_DISK" -o "$IMAGE_PATH"

# Vérifier si le fichier a bien été créé
ls -lh "$IMAGE_PATH"

# Vérification de l'intégrité de l'image
echo "Vérification de l'image..."
if sudo partclone.ext4 -r -s "$IMAGE_PATH" -o /dev/null; then
    echo "L'image est valide."
else
    echo "Erreur : L'image est invalide."
    rm -f "$IMAGE_PATH"
    exit 1
fi

# 2. Compression de l'image avec gzip
echo "Compression de l'image..."
gzip "$IMAGE_PATH"

# Vérifier si la compression a bien fonctionné
ls -lh "$COMPRESSED_IMAGE"

# Nettoyage : supprimer l'image non compressée
rm -f "$IMAGE_PATH"

echo "Sauvegarde terminée avec succès ! Fichier : $COMPRESSED_IMAGE"

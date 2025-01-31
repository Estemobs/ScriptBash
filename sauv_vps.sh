#!/bin/bash

# Définir les variables
SOURCE_DISK="/dev/sda"        # Le disque source (à adapter selon ton système)
BACKUP_DIR="/home/user/backups"  # Le répertoire pour stocker les images (peut être un disque externe ou un autre répertoire local)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")  # Timestamp pour nommer l'image
IMAGE_NAME="backup_$TIMESTAMP.img"
IMAGE_PATH="$BACKUP_DIR/$IMAGE_NAME"
COMPRESSED_IMAGE="$IMAGE_PATH.7z"  # Image compressée en 7z
REMOTE_CLOUD="remote:backup_folder"  # Le répertoire cloud configuré dans rclone

# 1. Créer l'image du système avec dd
echo "Création de l'image système..."
sudo dd if=$SOURCE_DISK of=$IMAGE_PATH bs=64K conv=noerror,sync status=none | pv -n > $IMAGE_PATH

# Vérifier si dd a réussi
if [ $? -eq 0 ]; then
    echo "L'image du disque a été créée avec succès."
else
    echo "Erreur lors de la création de l'image du disque."
    exit 1
fi

# 2. Vérification de l'intégrité de l'image
echo "Vérification de l'intégrité de l'image..."
sudo dd if=$IMAGE_PATH of=/dev/null bs=64K status=none | pv -n > /dev/null

if [ $? -eq 0 ]; then
    echo "L'image est valide."
else
    echo "Erreur : L'image est invalide. Suppression de l'image."
    rm -f $IMAGE_PATH
    exit 1
fi

# 3. Compression de l'image avec 7z
echo "Compression de l'image avec 7z..."
7z a -mx=9 -so $IMAGE_PATH | pv -n | 7z a $COMPRESSED_IMAGE > /dev/null

# Vérifier si la compression a réussi
if [ $? -eq 0 ]; then
    echo "L'image a été compressée avec succès."
else
    echo "Erreur lors de la compression de l'image."
    exit 1
fi

# 4. Vérification de la validité de l'image compressée
echo "Vérification de la validité de l'image compressée..."
7z t $COMPRESSED_IMAGE | pv -n > /dev/null

if [ $? -eq 0 ]; then
    echo "L'image compressée est valide."
else
    echo "Erreur : L'image compressée est invalide. Suppression de l'image compressée."
    rm -f $COMPRESSED_IMAGE
    exit 1
fi

# 5. Transfert de l'image vers le cloud via rclone
echo "Transfert de l'image vers le cloud..."
rclone copy $COMPRESSED_IMAGE $REMOTE_CLOUD --progress | pv -n > /dev/null

# Vérifier si le transfert vers le cloud a réussi
if [ $? -eq 0 ]; then
    echo "L'image a été transférée avec succès vers le cloud."
else
    echo "Erreur lors du transfert vers le cloud."
    exit 1
fi

# 6. Vérification de l'intégrité de l'image sur le cloud
echo "Vérification de l'intégrité de l'image sur le cloud..."

# On télécharge l'image depuis le cloud dans un fichier temporaire pour vérifier sa validité
rclone copy $REMOTE_CLOUD/$COMPRESSED_IMAGE /tmp/temp_backup.7z --progress | pv -n > /dev/null

# Vérifier l'intégrité du fichier téléchargé
7z t /tmp/temp_backup.7z | pv -n > /dev/null

if [ $? -eq 0 ]; then
    echo "L'image sur le cloud est valide."
    rm -f /tmp/temp_backup.7z  # Supprimer le fichier temporaire
else
    echo "Erreur : L'image sur le cloud est invalide."
    exit 1
fi

# 7. Supprimer l'image locale après un transfert réussi
echo "Suppression de l'image locale..."
rm -f $IMAGE_PATH
rm -f $COMPRESSED_IMAGE

echo "La sauvegarde et le transfert sont terminés avec succès !"

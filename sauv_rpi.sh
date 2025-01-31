#!/bin/bash

# Définir les variables
SOURCE_DISK="/dev/mmcblk0"  # Le disque source (généralement /dev/mmcblk0 pour le Raspberry Pi)
BACKUP_DIR="/mnt/usb"       # Le répertoire où le disque externe est monté (à adapter selon ton montage)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")  # Timestamp pour nommer l'image
IMAGE_NAME="backup_$TIMESTAMP.img"
IMAGE_PATH="$BACKUP_DIR/$IMAGE_NAME"
COMPRESSED_IMAGE="$IMAGE_PATH.gz"       # Image compressée
REMOTE_CLOUD="remote:backup_folder"     # Remplacer par le nom de ton répertoire cloud configuré dans rclone

# 1. Créer l'image du système avec dd
echo "Création de l'image système..."
sudo dd if=$SOURCE_DISK of=$IMAGE_PATH bs=64K conv=noerror,sync status=progress

# Vérifier si dd a réussi
if [ $? -eq 0 ]; then
    echo "L'image du disque a été créée avec succès."
else
    echo "Erreur lors de la création de l'image du disque."
    exit 1
fi

# 2. Compresser l'image pour économiser de l'espace
echo "Compression de l'image..."
gzip -c $IMAGE_PATH > $COMPRESSED_IMAGE

# Vérifier si la compression a réussi
if [ $? -eq 0 ]; then
    echo "L'image a été compressée avec succès."
else
    echo "Erreur lors de la compression de l'image."
    exit 1
fi

# 3. Vérification de l'intégrité de l'image compressée
echo "Vérification de l'intégrité de l'image..."
gunzip -t $COMPRESSED_IMAGE

# Vérifier si la commande de test a réussi
if [ $? -eq 0 ]; then
    echo "L'image compressée est valide."
else
    echo "Erreur : l'image compressée est corrompue."
    exit 1
fi

# 4. Copier l'image compressée sur le disque externe
echo "Transfert de l'image compressée sur le disque externe..."
cp $COMPRESSED_IMAGE $BACKUP_DIR

# Vérifier si le transfert a réussi
if [ $? -eq 0 ]; then
    echo "L'image compressée a été copiée avec succès sur le disque externe."
else
    echo "Erreur lors de la copie de l'image sur le disque externe."
    exit 1
fi

# 5. Transférer l'image vers le cloud via rclone
echo "Transfert de l'image vers le cloud..."
rclone copy $COMPRESSED_IMAGE $REMOTE_CLOUD

# Vérifier si le transfert vers le cloud a réussi
if [ $? -eq 0 ]; then
    echo "L'image a été transférée avec succès vers le cloud."
else
    echo "Erreur lors du transfert vers le cloud."
    exit 1
fi

# 6. Nettoyage (supprimer les fichiers locaux pour gagner de l'espace)
echo "Nettoyage des fichiers locaux..."
rm $IMAGE_PATH
rm $COMPRESSED_IMAGE

echo "La sauvegarde est terminée avec succès !"

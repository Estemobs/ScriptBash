#!/bin/bash

# Script pour ajouter automatiquement un hook `post-checkout` dans tous les dépôts Git

# Chemin vers le script de vérification de branche
CHECK_BRANCH_SCRIPT=~/scripts/check-branch.sh

# Crée le script check-branch.sh si il n'existe pas
if [ ! -f "$CHECK_BRANCH_SCRIPT" ]; then
  echo "Création du script check-branch.sh..."
  cat <<EOL > $CHECK_BRANCH_SCRIPT
#!/bin/bash

# Vérifie la branche actuelle
current_branch=\$(git symbolic-ref --short HEAD)

# Si on est sur la branche master, avertir l'utilisateur
if [ "\$current_branch" == "master" ]; then
    echo "Attention: Vous êtes sur la branche 'master'. Veuillez passer à 'mymaster' pour faire des modifications."
    echo "Pour cela, utilisez la commande : git checkout mymaster"
fi
EOL
  chmod +x $CHECK_BRANCH_SCRIPT
fi

echo "Le script check-branch.sh est prêt."

# Recherche tous les dépôts Git sur le système (répertoire courant et sous-répertoires)
echo "Recherche des dépôts Git..."

# Chemin du répertoire où chercher les dépôts
# Change ce chemin si tu veux spécifier un dossier particulier (ex: ~/Projects)
SEARCH_DIR=~/  # Rechercher dans tout le home directory

# Parcours tous les dépôts Git
find $SEARCH_DIR -type d -name ".git" | while read git_dir; do
  repo_dir=$(dirname $git_dir)

  # Vérifie si le hook post-checkout existe déjà
  if [ ! -f "$repo_dir/.git/hooks/post-checkout" ]; then
    echo "Ajout du hook post-checkout pour le dépôt $repo_dir"
    
    # Créer le hook post-checkout avec le script de vérification
    echo '#!/bin/bash' > "$repo_dir/.git/hooks/post-checkout"
    echo "$CHECK_BRANCH_SCRIPT" >> "$repo_dir/.git/hooks/post-checkout"
    
    # Rendre le hook exécutable
    chmod +x "$repo_dir/.git/hooks/post-checkout"
  else
    echo "Le hook post-checkout existe déjà pour le dépôt $repo_dir"
  fi
done

echo "Le script a été exécuté pour tous les dépôts."

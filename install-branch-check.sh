#!/bin/bash

# Script pour ajouter automatiquement un hook `post-checkout` dans tous les dépôts Git

# Recherche tous les dépôts Git sur le système (répertoire courant et sous-répertoires)
echo "Recherche des dépôts Git..."

# Chemin du répertoire où chercher les dépôts
# Change ce chemin si tu veux spécifier un dossier particulier (ex: ~/Projects)
SEARCH_DIR=~/  # Rechercher dans tout le home directory

# Parcours tous les dépôts Git
find $SEARCH_DIR -type d -name ".git" | while read git_dir; do
  repo_dir=$(dirname $git_dir)

  # Remplacer le hook post-checkout, même s'il existe déjà
  echo "Remplacement du hook post-checkout pour le dépôt $repo_dir"
    
  # Créer ou écraser le hook post-checkout avec le code intégré pour vérifier la branche
  sudo tee "$repo_dir/.git/hooks/post-checkout" > /dev/null <<'EOL'
#!/bin/bash

# Vérifie la branche actuelle
branch=$(git symbolic-ref --short HEAD)

# Si on est sur la branche master, avertir l'utilisateur
if [ "$branch" = "master" ]; then
    echo "Commits directs sur la branche master ne sont pas autorisés. Veuillez utiliser une pull request."
    echo "Pour cela, utilisez la commande : git checkout mymaster"
    exit 1
fi
EOL

  # Rendre le hook exécutable avec sudo
  sudo chmod +x "$repo_dir/.git/hooks/post-checkout"

done

echo "Le script a été exécuté pour tous les dépôts."

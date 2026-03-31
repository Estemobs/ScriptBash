#!/bin/bash

# Script pour ajouter automatiquement un hook `pre-commit` dans tous les dépôts Git
# Ce hook empêche les commits directs sur les branches master et main

echo "Recherche des dépôts Git..."

# Chemin du répertoire où chercher les dépôts
# Change ce chemin si tu veux spécifier un dossier particulier (ex: ~/Projects)
SEARCH_DIR="$HOME"

REPO_COUNT=0

# Parcours tous les dépôts Git (process substitution pour conserver les variables hors de la boucle)
while IFS= read -r git_dir; do
  repo_dir=$(dirname "$git_dir")
  REPO_COUNT=$((REPO_COUNT + 1))

  # Remplacer le hook pre-commit, même s'il existe déjà
  echo "Installation du hook pre-commit pour le dépôt : $repo_dir"

  # Créer ou écraser le hook pre-commit avec le code intégré pour vérifier la branche
  sudo tee "$repo_dir/.git/hooks/pre-commit" > /dev/null <<'EOL'
#!/bin/bash

# Vérifie la branche actuelle
branch=$(git symbolic-ref --short HEAD 2>/dev/null)

# Si on est sur la branche master ou main, bloquer le commit direct
if [ "$branch" = "master" ] || [ "$branch" = "main" ]; then
    echo "❌ Commits directs sur la branche '$branch' ne sont pas autorisés."
    echo "👉 Veuillez créer une branche de travail et utiliser une pull request :"
    echo "   git checkout -b ma-branche"
    exit 1
fi
EOL

  # Rendre le hook exécutable avec sudo
  sudo chmod +x "$repo_dir/.git/hooks/pre-commit"

done < <(find "$SEARCH_DIR" -type d -name ".git" 2>/dev/null)

if [ "$REPO_COUNT" -eq 0 ]; then
  echo "Aucun dépôt Git trouvé dans $SEARCH_DIR."
else
  echo "✅ Hook pre-commit installé dans $REPO_COUNT dépôt(s) Git."
fi

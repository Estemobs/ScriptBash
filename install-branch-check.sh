#!/bin/bash

# Installe un hook pre-commit qui bloque les commits directs sur master/main.
# Comportement par defaut:
# - scan uniquement ~/Documents
# - simulation (dry-run)
# - scan premier niveau uniquement

set -u

SCRIPT_NAME="$(basename "$0")"
MANAGED_MARKER="# managed-by=install-branch-check.sh"
APPLY=false
CLEANUP=false
INCLUDE_NESTED=false
ASSUME_YES=false
MAXDEPTH=5

declare -a TARGETS=()
declare -a DEFAULT_TARGETS=("$HOME/Documents")
declare -a EXCLUDED_PREFIXES=(
  "$HOME/.cache"
  "$HOME/.pub-cache"
  "$HOME/.local"
  "$HOME/.config"
)

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Options:
  --target <path>       Ajouter une cible de scan (repeatable)
  --targets <a,b,c>     Ajouter plusieurs cibles de scan separees par des virgules
  --nested              Autoriser les depots imbriques (sinon: premier niveau seulement)
  --maxdepth <n>        Profondeur max du scan en mode --nested (defaut: $MAXDEPTH)
  --cleanup             Nettoyer les hooks signes par ce script dans les caches systeme
  --apply               Appliquer les changements (sinon: simulation)
  -y, --yes             Ne pas demander de confirmation
  -h, --help            Afficher cette aide

Exemples:
  $SCRIPT_NAME
  $SCRIPT_NAME --apply
  $SCRIPT_NAME --target ~/projects --apply
  $SCRIPT_NAME --cleanup --apply
EOF
}

expand_path() {
  local input="$1"
  if [[ "$input" == "~" ]]; then
    printf '%s\n' "$HOME"
  elif [[ "$input" == ~/* ]]; then
    printf '%s\n' "$HOME/${input#~/}"
  else
    printf '%s\n' "$input"
  fi
}

is_excluded_repo() {
  local repo="$1"
  local prefix

  for prefix in "${EXCLUDED_PREFIXES[@]}"; do
    if [[ "$repo" == "$prefix"* ]]; then
      return 0
    fi
  done

  if [[ "$repo" == *"/node_modules/"* ]] || [[ "$repo" == *"/node_modules" ]]; then
    return 0
  fi
  if [[ "$repo" == *"/.venv/"* ]] || [[ "$repo" == *"/.venv" ]]; then
    return 0
  fi
  if [[ "$repo" == *"/venv/"* ]] || [[ "$repo" == *"/venv" ]]; then
    return 0
  fi

  return 1
}

confirm_or_abort() {
  local message="$1"
  if $ASSUME_YES; then
    return 0
  fi

  read -r -p "$message [y/N] " answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Operation annulee."
    exit 0
  fi
}

append_target() {
  local value
  value="$(expand_path "$1")"
  TARGETS+=("$value")
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -lt 2 ]] && { echo "Erreur: --target attend un chemin."; exit 1; }
      append_target "$2"
      shift 2
      ;;
    --targets)
      [[ $# -lt 2 ]] && { echo "Erreur: --targets attend une liste."; exit 1; }
      IFS=',' read -r -a split_targets <<< "$2"
      for t in "${split_targets[@]}"; do
        [[ -n "$t" ]] && append_target "$t"
      done
      shift 2
      ;;
    --nested)
      INCLUDE_NESTED=true
      shift
      ;;
    --maxdepth)
      [[ $# -lt 2 ]] && { echo "Erreur: --maxdepth attend un nombre."; exit 1; }
      MAXDEPTH="$2"
      if ! [[ "$MAXDEPTH" =~ ^[0-9]+$ ]]; then
        echo "Erreur: --maxdepth doit etre un entier >= 0."
        exit 1
      fi
      shift 2
      ;;
    --cleanup)
      CLEANUP=true
      shift
      ;;
    --apply)
      APPLY=true
      shift
      ;;
    -y|--yes)
      ASSUME_YES=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Option inconnue: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=("${DEFAULT_TARGETS[@]}")
fi

if $APPLY && $CLEANUP; then
  confirm_or_abort "Tu es sur le point d'ecrire et nettoyer des hooks. Continuer ?"
fi

echo "Configuration:"
echo "  Mode: $([[ "$APPLY" == true ]] && echo "APPLY" || echo "DRY-RUN")"
echo "  Cibles: ${TARGETS[*]}"
echo "  Depot imbriques: $([[ "$INCLUDE_NESTED" == true ]] && echo "oui" || echo "non (premier niveau)")"
echo "  Nettoyage cache/systeme: $([[ "$CLEANUP" == true ]] && echo "oui" || echo "non")"

declare -A SEEN_REPOS=()
declare -a REPOS=()
SCANNED=0
INSTALLED=0
SKIPPED=0
CLEANED=0
ERRORS=0

echo "Recherche des depots Git..."

for target in "${TARGETS[@]}"; do
  if [[ ! -d "$target" ]]; then
    echo "[SKIP] Cible introuvable: $target"
    continue
  fi

  if $INCLUDE_NESTED; then
    while IFS= read -r git_dir; do
      repo_dir="$(dirname "$git_dir")"
      SCANNED=$((SCANNED + 1))

      if is_excluded_repo "$repo_dir"; then
        SKIPPED=$((SKIPPED + 1))
        echo "[SKIP] Hors perimetre: $repo_dir"
        continue
      fi

      if [[ -n "${SEEN_REPOS[$repo_dir]+x}" ]]; then
        continue
      fi

      SEEN_REPOS["$repo_dir"]=1
      REPOS+=("$repo_dir")
    done < <(find "$target" -maxdepth "$MAXDEPTH" -type d -name ".git" 2>/dev/null)
  else
    while IFS= read -r git_dir; do
      repo_dir="$(dirname "$git_dir")"
      SCANNED=$((SCANNED + 1))

      if is_excluded_repo "$repo_dir"; then
        SKIPPED=$((SKIPPED + 1))
        echo "[SKIP] Hors perimetre: $repo_dir"
        continue
      fi

      if [[ -n "${SEEN_REPOS[$repo_dir]+x}" ]]; then
        continue
      fi

      SEEN_REPOS["$repo_dir"]=1
      REPOS+=("$repo_dir")
    done < <(find "$target" -maxdepth 2 -type d -name ".git" 2>/dev/null)
  fi
done

if [[ ${#REPOS[@]} -eq 0 ]]; then
  echo "Aucun depot Git retenu pour l'installation."
else
  for repo_dir in "${REPOS[@]}"; do
    hook_file="$repo_dir/.git/hooks/pre-commit"

    if ! $APPLY; then
      echo "[DRY-RUN][INSTALL] $repo_dir"
      continue
    fi

    echo "[INSTALL] $repo_dir"

    if ! tee "$hook_file" > /dev/null <<'EOL'; then
#!/bin/bash

# managed-by=install-branch-check.sh

branch=$(git symbolic-ref --short HEAD 2>/dev/null)

if [ "$branch" = "master" ] || [ "$branch" = "main" ]; then
    echo "Les commits directs sur la branche '$branch' ne sont pas autorises."
    echo "Cree une branche de travail puis fais une pull request."
    echo "Exemple: git checkout -b ma-branche"
    exit 1
fi
EOL
      echo "[ERROR] Echec d'ecriture du hook: $hook_file"
      ERRORS=$((ERRORS + 1))
      continue
    fi

    if ! chmod +x "$hook_file"; then
      echo "[ERROR] Echec chmod +x: $hook_file"
      ERRORS=$((ERRORS + 1))
      continue
    fi

    INSTALLED=$((INSTALLED + 1))
  done
fi

if $CLEANUP; then
  echo "Nettoyage des hooks geres dans les repertoires cache/systeme..."

  for prefix in "${EXCLUDED_PREFIXES[@]}"; do
    [[ -d "$prefix" ]] || continue

    while IFS= read -r git_dir; do
      repo_dir="$(dirname "$git_dir")"
      hook_file="$repo_dir/.git/hooks/pre-commit"

      [[ -f "$hook_file" ]] || continue
      grep -q "$MANAGED_MARKER" "$hook_file" || continue

      if ! $APPLY; then
        echo "[DRY-RUN][CLEANUP] $hook_file"
        continue
      fi

      if rm -f "$hook_file"; then
        echo "[CLEANUP] $hook_file"
        CLEANED=$((CLEANED + 1))
      else
        echo "[ERROR] Impossible de supprimer: $hook_file"
        ERRORS=$((ERRORS + 1))
      fi
    done < <(find "$prefix" -type d -name ".git" 2>/dev/null)
  done
fi

echo
echo "Resume:"
echo "  Depots scannes: $SCANNED"
echo "  Depots retenus: ${#REPOS[@]}"
echo "  Depots ignores: $SKIPPED"
echo "  Hooks installes: $INSTALLED"
echo "  Hooks nettoyes: $CLEANED"
echo "  Erreurs: $ERRORS"

if ! $APPLY; then
  echo "Simulation terminee. Ajoute --apply pour appliquer les changements."
fi

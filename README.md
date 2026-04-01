### Procédure : Configurer l'authentification SSH pour Git (git push) sans mot de passe dans VS Code

Pour permettre à **VS Code** d'utiliser **Git** avec l'authentification SSH sans mot de passe (par exemple, lors d'un `git push`), suivez ces étapes :

1. **Démarrer l'agent SSH**  
   L'agent SSH gère vos clés privées et les met à disposition pour les connexions SSH, y compris pour les opérations Git. Exécutez la commande suivante pour démarrer l'agent SSH :

   ```bash
   eval "$(ssh-agent -s)"
   ```

2. **Ajouter la clé SSH à l'agent**  
   Ajoutez votre clé privée SSH à l'agent pour permettre une connexion Git sans mot de passe. Utilisez la commande suivante (remplacez `id_rsa_new` par le nom de votre clé si nécessaire) :

   ```bash
   ssh-add ~/.ssh/id_rsa_new
   ```


### Planification (crontab)

Vous pouvez automatiser l'exécution des scripts via `cron`. Ouvrez votre crontab avec :

```bash
crontab -e
```

> **Précautions importantes**
> - `cron` utilise un **PATH minimal** (`/usr/bin:/bin`). Définissez `PATH` en tête de crontab ou utilisez des chemins absolus.
> - Certains scripts (ex. `sauv-sys.sh`) nécessitent `sudo` ; dans ce cas éditez la crontab root : `sudo crontab -e`.
> - Redirigez toujours la sortie vers un fichier de log pour pouvoir diagnostiquer les erreurs.

**Exemples copiables**

```cron
# Définir un PATH minimal pour cron
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Mettre à jour tous les paquets chaque jour à 3h00 (log dans ~/logs/update_all.log)
0 3 * * * /bin/bash /chemin/vers/update_all.sh >> ~/logs/update_all.log 2>&1

# Sauvegarde système chaque semaine le dimanche à 2h00 (nécessite sudo crontab -e)
0 2 * * 0 /bin/bash /chemin/vers/sauv-sys.sh >> /var/log/sauv-sys.log 2>&1
```

**Dry-run (simulation)**

Pour tester `update_all.sh` sans appliquer de changements, ajoutez l'option `-s` (simulate) à `apt-get` ou lancez le script manuellement et vérifiez les logs avant de l'ajouter à crontab.



### Description des scripts Bash

- **update_all.sh** : Met à jour tous les paquets APT, Snap, Flatpak, AppImage et .deb installés manuellement. ✅
- **sauv-sys.sh** : Sauvegarde les paquets installés, configurations et fichiers importants du système. V1 ✅
- **ip_scanner.sh** : Scanne le réseau local pour détecter les hôtes actifs et leurs informations. ✅
- **bot_discord.sh** : Démarre les bots Discord DDC et cocoyico. ✅
- **install-branch-check.sh** : Ajoute un hook `pre-commit` pour bloquer les commits directs sur `master` et `main`, limite le scan aux projets perso et supporte un mode cleanup securise. ✅

### Utilisation de install-branch-check.sh

- Par defaut: scan uniquement `~/Documents`, en simulation (dry-run), premier niveau uniquement.
- Pour appliquer les changements:

```bash
./install-branch-check.sh --apply
```

- Pour ajouter des cibles de scan:

```bash
./install-branch-check.sh --target ~/projects --target ~/dev --apply
```

- Pour autoriser les depots imbriques:

```bash
./install-branch-check.sh --nested --maxdepth 6 --apply
```

- Pour nettoyer les hooks poses par erreur dans les caches/systeme (uniquement ceux signes par ce script):

```bash
./install-branch-check.sh --cleanup --apply
```



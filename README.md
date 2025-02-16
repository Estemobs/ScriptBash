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

   CRONTAB BIENTOT 

### Description des scripts Bash

- **update_all.sh** : Met à jour tous les paquets APT, Snap, Flatpak, AppImage et .deb installés manuellement. ✅
- **sauv-sys.sh** : Sauvegarde les paquets installés, configurations et fichiers importants du système.
- **sauv_vps.sh** : Crée une image du disque d'un VPS, la compresse et la transfère vers le cloud.
- **sauv_rpi.sh** : Crée une image du disque d'un Raspberry Pi, la compresse et la transfère vers le cloud.
- **ip_scanner.sh** : Scanne le réseau local pour détecter les hôtes actifs et leurs informations. ✅
- **bot_discord.sh** : Démarre les bots Discord DDC et cocoyico. ✅
- **backup_system.sh** : Monte un disque, initialise un dépôt Restic et crée une sauvegarde du système.

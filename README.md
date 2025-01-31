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

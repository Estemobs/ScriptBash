### Procédure : Démarrer l'agent SSH et ajouter une clé pour l'authentification sans mot de passe dans VS Code

Pour configurer l'authentification SSH sans mot de passe dans **VS Code**, suivez ces étapes :

1. **Démarrer l'agent SSH**  
   L'agent SSH gère vos clés privées et les met à disposition pour les connexions SSH. Exécutez la commande suivante pour démarrer l'agent SSH :

   ```bash
   eval "$(ssh-agent -s)"
   ```

2. **Ajouter la clé SSH à l'agent**  
   Ajoutez votre clé privée SSH à l'agent pour permettre l'authentification sans mot de passe. Utilisez la commande suivante (remplacez `id_rsa_new` par le nom de votre clé si nécessaire) :

   ```bash
   ssh-add ~/.ssh/id_rsa_new
   ```

   CRONTAB BIENTOT 

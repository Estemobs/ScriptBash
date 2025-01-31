Crontab ici

###Procédure démarrage de l'agent SSH et ajouter une clé pour l'authentification sans mot de passe dans VS Code

# Démarrer l'agent SSH
eval "$(ssh-agent -s)"

# Ajouter la clé SSH à l'agent SSH
ssh-add ~/.ssh/id_rsa_new

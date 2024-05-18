#!/bin/bash

# Démarrer l'agent SSH
eval "$(ssh-agent -s)"

# Ajouter la clé SSH à l'agent SSH
ssh-add ~/.ssh/id_rsa_new

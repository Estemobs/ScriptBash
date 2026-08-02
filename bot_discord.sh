#!/bin/bash
sleep 30
wait
cd /home/estemobs/partage/ddcbot || exit 1
echo "Démarrage de DDC bot"
nohup python main.py &
cd /home/estemobs/partage/cocoyico || exit 1
echo "Démarrage de cocoyico"
nohup python cocoyico.py &



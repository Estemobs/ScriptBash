#!/bin/bash
sleep 30
wait
cd /home/estemobs/partage/ddcbot
echo "Démarrage de DDC bot"
nohup python main.py &
cd /home/estemobs/partage/cocoyico
echo "Démarrage de cocoyico"
nohup python cocoyico.py &



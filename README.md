# ScriptBash

Collection de scripts Bash utilitaires pour l'administration système Linux.

## Scripts

| Script | Description |
|--------|-------------|
| `update_all.sh` | Met à jour tous les paquets APT, Snap, Flatpak et AppImage |
| `sauv-sys.sh` | Sauvegarde des paquets installés, configs et fichiers importants |
| `ip_scanner.sh` | Scanne le réseau local pour détecter les hôtes actifs |
| `bot_discord.sh` | Démarre les bots Discord DDC et cocoyico |
| `install-branch-check.sh` | Hook pre-commit pour bloquer les commits sur master/main |
| `disk_log_monitor.sh` | Surveillance de l'espace disque |
| `driver_update_check.sh` | Vérification des mises à jour de drivers |
| `ssh_check.sh` | Vérification des connexions SSH |
| `temp_email_alerts.sh` | Alerte email en cas de température excessive |
| `resource_report.sh` | Rapport d'utilisation des ressources système |
| `usb_eject.sh` | Éjection sécurisée de périphériques USB |

## Utilisation

```bash
chmod +x script.sh
./script.sh
```

Certains scripts nécessitent `sudo` (sauv-sys.sh, update_all.sh). Pour la planification automatique, voir la section crontab dans chaque script.

## Licence

MIT

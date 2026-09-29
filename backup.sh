#!/usr/bin/env bash
# Ночная копия базы. База — это папка data/pglite, поэтому на несколько секунд останавливаем сервис,
# чтобы копия получилась целой.
set -e
DEST=/var/backups/mostik
mkdir -p "$DEST"
systemctl stop mostik
tar -czf "$DEST/mostik-data-$(date +%F).tar.gz" -C /opt/mostik data
systemctl start mostik
# хранить последние 14 копий
ls -1t "$DEST"/mostik-data-*.tar.gz | tail -n +15 | xargs -r rm -f

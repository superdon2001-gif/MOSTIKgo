#!/usr/bin/env bash
# Установка MOSTIK на чистый сервер Ubuntu 22.04/24.04.
# Запускать от root из папки проекта:   bash deploy/install.sh ВАШ.ДОМЕН
# Домен должен уже указывать (A-запись) на IP этого сервера — иначе HTTPS-сертификат не выдастся.
set -euo pipefail

DOMAIN="${1:-}"
[ -n "$DOMAIN" ] || { echo "Укажите домен:  bash deploy/install.sh mostik.example.com"; exit 1; }
[ "$(id -u)" = 0 ] || { echo "Запустите от root"; exit 1; }
cd /opt/mostik
[ -f server.mjs ] || { echo "Проект должен лежать в /opt/mostik (нет server.mjs)"; exit 1; }
export DEBIAN_FRONTEND=noninteractive

echo "==> Базовые пакеты"
apt-get update
apt-get install -y curl unzip ca-certificates gnupg debian-keyring debian-archive-keyring apt-transport-https

echo "==> Node.js 22"
NODE_MAJOR=0
command -v node >/dev/null 2>&1 && NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$NODE_MAJOR" -lt 20 ]; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  apt-get install -y nodejs
fi
node --version

echo "==> Caddy (HTTPS автоматически)"
if ! command -v caddy >/dev/null 2>&1; then
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' > /etc/apt/sources.list.d/caddy-stable.list
  apt-get update
  apt-get install -y caddy
fi

echo "==> Своп (если памяти мало)"
MEM_MB="$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)"
if [ "$MEM_MB" -lt 1800 ] && ! swapon --show | grep -q .; then
  fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
  grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

echo "==> Пользователь и права"
id mostik >/dev/null 2>&1 || useradd --system --home /opt/mostik --shell /usr/sbin/nologin mostik
mkdir -p /opt/mostik/data
rm -f /opt/mostik/data/pglite/postmaster.pid   # остаток от Windows-версии, сервер сам создаст заново
chown -R mostik:mostik /opt/mostik

echo "==> Блокировка демо-аккаунтов (demo123 известен всем)"
systemctl stop mostik 2>/dev/null || true
runuser -u mostik -- node deploy/lock-demo-accounts.mjs

echo "==> Служба и Caddy"
sed "s/__DOMAIN__/$DOMAIN/g" deploy/mostik.service > /etc/systemd/system/mostik.service
sed "s/__DOMAIN__/$DOMAIN/g" deploy/Caddyfile > /etc/caddy/Caddyfile
systemctl daemon-reload
systemctl enable --now mostik
systemctl restart caddy

if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
  ufw allow 22/tcp; ufw allow 80/tcp; ufw allow 443/tcp
fi

echo "==> Ночная копия базы (04:00)"
chmod +x deploy/backup.sh
echo "0 4 * * * root /opt/mostik/deploy/backup.sh >/dev/null 2>&1" > /etc/cron.d/mostik-backup

sleep 5
systemctl --no-pager --lines=5 status mostik || true
echo
echo "Проверка:  curl -s http://127.0.0.1:8787/api/health"
curl -s http://127.0.0.1:8787/api/health || true
echo
echo "Готово. Откройте https://$DOMAIN (сертификат может появиться через минуту)."
echo "Логи: journalctl -u mostik -f"

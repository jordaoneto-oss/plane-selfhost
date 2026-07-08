#!/bin/bash
set -e

echo "=== Plane Self-Hosted Setup ==="

# Configurar .env
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Criado .env a partir de .env.example"
fi

if [ ! -f apps/api/.env ]; then
    mkdir -p apps/api
    cp apps/api/.env.example apps/api/.env
    echo "Criado apps/api/.env a partir de .env.example"
fi

# Pedir IP
read -p "Digite o IP ou dominio para acessar o Plane (ex: 192.168.0.36): " APP_URL
if [ -n "$APP_URL" ]; then
    if [[ "$APP_URL" != http* ]]; then
        APP_URL="http://$APP_URL"
    fi
    sed -i "s|http://192.168.0.36|$APP_URL|g" apps/api/.env
    sed -i "s|SITE_ADDRESS=.*|SITE_ADDRESS=$APP_URL|" .env
    echo "URL configurada: $APP_URL"
fi

# Iniciar
echo ""
echo "Iniciando containers..."
docker compose up -d

echo ""
echo "=== Pronto! ==="
echo "Acesse: $APP_URL"
echo "Admin:  $APP_URL/god-mode"
echo ""
echo "O primeiro usuario a se cadastrar sera o administrador."

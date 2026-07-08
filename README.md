# Plane - Self-Hosted Stack

[Plane](https://github.com/makeplane/plane) é uma plataforma open-source de gerenciamento de projetos, alternativa a Jira, Linear e Asana.

Esta stack inclui:
- **Plane** — gestão de projetos (issues, cycles, modules, páginas)
- **Authelia** — SSO/OIDC (login centralizado)
- **n8n** — automação de workflows (webhooks, integrações)
- **Outline** — wiki/knowledge base (com autenticação via Authelia)

## Requisitos

- Docker + Docker Compose
- 4GB RAM (recomendado 8GB com addons)
- 20GB disco

## Setup rapido

```bash
# 1. Clone este repositorio
git clone https://github.com/jordaoneto-oss/plane-selfhost.git
cd plane-selfhost

# 2. Configure o .env
cp .env.example .env
cp apps/api/.env.example apps/api/.env

# 3. Edite o APP_BASE_URL em apps/api/.env para seu IP/dominio
#    Ex: APP_BASE_URL=http://192.168.0.36

# 4. Inicie o Plane
docker compose up -d

# 5. Acesse http://SEU_IP
```

### Stack complementar (opcional)

```bash
# Entre na pasta de addons
cd plane-addons

# Edite as configurações do Authelia se necessario
#   - senha admin: editar authelia/config/users.yml
#   - dominio: editar authelia/config/configuration.yml

# Inicie os addons
docker compose up -d
```

## Acesso

| Servico | URL | Credenciais |
|---------|-----|-------------|
| **Plane** (web) | `http://SEU_IP` | jordaosneto@hotmail.com |
| **Plane** (admin) | `http://SEU_IP/god-mode` | (mesmo usuario) |
| **Plane** (spaces) | `http://SEU_IP/spaces` | (mesmo usuario) |
| **Authelia** (SSO) | `https://SEU_IP:9091` | admin / plane2024 |
| **n8n** (automacao) | `http://SEU_IP:5678` | jordaosneto@hotmail.com / Plane2024 |
| **Outline** (wiki) | `http://SEU_IP:3001` | login via Authelia (OIDC) |
| **MinIO** (storage) | `http://SEU_IP:9000` | access-key / secret-key |

## Funcionalidades ativas

- Login com email e senha
- Magic Link
- Login Google / GitHub / GitLab (requer credenciais dos portais)
- Upload via MinIO (S3-compativel)
- Cycles, Modules, Pages, Views
- **SSO via Authelia** (protege rotas /api, /auth, /spaces, /live)
- **Integracao n8n** (webhooks para automatizar fluxos)
- **Wiki corporativa** (Outline com login OIDC)

## Arquitetura

```
Proxy (nginx) -> Porta 80
  +-- /        -> web (Next.js)
  +-- /api     -> api (Django)
  +-- /auth    -> api (Django)
  +-- /god-mode -> admin (Next.js)
  +-- /live    -> live (Next.js)
  +-- /spaces  -> space (Next.js)

Addons:
  +-- Authelia (porta 9091, TLS auto-assinado)
  +-- n8n       (porta 5678)
  +-- Outline   (porta 3001)

Banco: PostgreSQL 15 (plane + addons)
Cache: Valkey (Redis) + Redis (addons)
Queue: RabbitMQ
Storage: MinIO (S3)
```

## Integracao n8n + Plane

1. Acesse n8n em `http://SEU_IP:5678`
2. Crie um workflow com trigger **Webhook**
3. Em Plane, vá em **Configuracoes > Webhooks** e aponte para:
   `http://SEU_IP:5678/webhook/SEU-WEBHOOK-ID`
4. Use a chave de API do Plane (gerada em Configuracoes > API Tokens)

### Webhook criado automaticamente

A stack ja inclui um workflow "Plane Webhook Handler" no n8n com:
- Endpoint: `POST http://SEU_IP:5678/webhook/plane-webhook`
- Extrai dados do payload (action, issue_id)
- Roteia por tipo de acao (issue.created, issue.updated)

Para ativar: edite o workflow no n8n e clique em "Active".

## Comandos Uteis

```bash
# Logs do Plane
docker compose logs -f api
docker compose logs -f web

# Logs dos addons
docker compose -f plane-addons/docker-compose.yml logs -f n8n
docker compose -f plane-addons/docker-compose.yml logs -f outline
docker compose -f plane-addons/docker-compose.yml logs -f authelia

# Reiniciar servico
docker compose restart api

# Parar tudo
docker compose down
docker compose -f plane-addons/docker-compose.yml down

# Atualizar imagens
docker compose pull
docker compose up -d
```

## Troubleshooting

**Authelia nao sobe:**
```bash
docker logs authelia
# Se erro de NTP, verifique se o relogio da VM esta sincronizado
sudo timedatectl set-ntp true
```

**Outline com erro de banco:**
```bash
# Resetar schema do banco (cuidado: perde dados)
docker exec addons-db psql -U addons -d addons -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
docker restart outline
```

**n8n lento:**
A VM com 4GB pode ficar sobrecarregada com 17 containers. Considere aumentar para 8GB ou rodar addons seletivamente.

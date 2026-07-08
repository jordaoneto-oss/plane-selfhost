# Plane - Self-Hosted

[Plane](https://github.com/makeplane/plane) é uma plataforma open-source de gerenciamento de projetos, alternativa a Jira, Linear e Asana.

## Requisitos

- Docker + Docker Compose
- 4GB RAM
- 10GB disco

## Setup rapido

```bash
# 1. Clone este repositorio
git clone https://github.com/jordaoneto-oss/plane-selfhost.git
cd plane-selfhost

# 2. Configure o .env (veja .env.example)
cp .env.example .env
cp apps/api/.env.example apps/api/.env

# 3. Edite o APP_BASE_URL em apps/api/.env para seu IP/dominio
#    Ex: APP_BASE_URL=http://192.168.0.36

# 4. Inicie
docker compose up -d

# 5. Acesse http://SEU_IP
```

## Acesso

| Servico | URL |
|---------|-----|
| App | http://SEU_IP |
| Admin (god-mode) | http://SEU_IP/god-mode |
| API | http://SEU_IP/api |

## Funcionalidades ativas

- Login com email e senha
- Magic Link (ENABLE_MAGIC_LINK_LOGIN=1)
- Login Google (requer configurar GOOGLE_CLIENT_ID)
- Login GitHub (requer configurar GITHUB_CLIENT_ID)
- Login GitLab (requer configurar GITLAB_CLIENT_ID)
- Upload de arquivos via MinIO (S3-compativel)
- Cycles, Modules, Pages, Views

## Comandos utcis

```bash
# Logs
docker compose logs -f api
docker compose logs -f web

# Reiniciar servico
docker compose restart api

# Parar tudo
docker compose down

# Atualizar imagens
docker compose pull
docker compose up -d
```

## Arquitetura

```
Proxy (nginx) -> Porta 80
  ├── /        -> web (Next.js)
  ├── /api     -> api (Django)
  ├── /auth    -> api (Django)
  ├── /god-mode -> admin (Next.js)
  ├── /live    -> live (Next.js)
  └── /spaces  -> space (Next.js)

Banco: PostgreSQL 15
Cache: Valkey (Redis)
Queue: RabbitMQ
Storage: MinIO
```

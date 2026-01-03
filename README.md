# Ansible Roles для развертывания nginx с Docker Compose

Этот проект содержит Ansible роли для установки Docker Engine и развертывания nginx с использованием Docker Compose v2.

## Структура проекта

```
.
├── roles/
│   ├── docker_engine/      # Установка Docker Engine и Docker Compose v2
│   └── nginx_compose/       # Развертывание nginx через Docker Compose
├── playbook.yml            # Основной playbook
├── requirements.yml        # Зависимости (коллекции)
└── README.md              # Документация
```

## Требования

- Ansible >= 2.14
- Управляемые хосты: Ubuntu (jammy, noble) или Debian (bullseye, bookworm)
- Для RHEL-подобных систем: RHEL, Fedora, Rocky, AlmaLinux

## Установка зависимостей

```bash
ansible-galaxy collection install -r requirements.yml
```

## Использование

### Базовое использование

```bash
ansible-playbook -i inventory playbook.yml
```

### Пример inventory файла

```ini
[webservers]
web1 ansible_host=192.168.1.10 ansible_user=ubuntu
web2 ansible_host=192.168.1.11 ansible_user=ubuntu
```

### Переопределение переменных

Создайте файл `group_vars/all.yml` или передайте переменные через `-e`:

```yaml
# Настройки Docker Engine
docker_engine_enable_service: true
docker_engine_start_service: true
docker_engine_manage_docker_group: true
docker_engine_docker_users:
  - ubuntu
  - ansible

# Настройки nginx
nginx_compose_project_dir: /opt/nginx-compose
nginx_compose_project_name: nginx_stack
nginx_compose_service_name: nginx
nginx_compose_image: "nginx:stable-alpine"
nginx_compose_host_port: 80
nginx_compose_container_port: 80
nginx_compose_restart: "unless-stopped"
```

### Пример запуска с переменными

```bash
ansible-playbook -i inventory playbook.yml \
  -e "nginx_compose_host_port=8080" \
  -e "docker_engine_docker_users=['ubuntu']"
```

## Роли

### docker_engine

Устанавливает Docker Engine и Docker Compose v2 plugin.

**Переменные:**
- `docker_engine_enable_service` (default: `true`) - включить автозапуск Docker
- `docker_engine_start_service` (default: `true`) - запустить Docker сервис
- `docker_engine_manage_docker_group` (default: `false`) - управлять группой docker
- `docker_engine_docker_users` (default: `[]`) - список пользователей для добавления в группу docker

**Поддерживаемые ОС:**
- Debian/Ubuntu (Debian-based)
- RHEL/Fedora/Rocky/AlmaLinux (RedHat-based)

### nginx_compose

Развертывает nginx контейнер через Docker Compose v2.

**Переменные:**
- `nginx_compose_project_dir` (default: `/opt/nginx-compose`) - директория проекта
- `nginx_compose_project_name` (default: `nginx_stack`) - имя проекта Compose
- `nginx_compose_service_name` (default: `nginx`) - имя сервиса
- `nginx_compose_image` (default: `nginx:stable-alpine`) - образ Docker
- `nginx_compose_host_port` (default: `80`) - порт на хосте
- `nginx_compose_container_port` (default: `80`) - порт в контейнере
- `nginx_compose_restart` (default: `unless-stopped`) - политика перезапуска

## Развертывание на виртуальной машине

Для развертывания на виртуальной машине см. подробную инструкцию: [DEPLOY_VM.md](DEPLOY_VM.md)

Быстрый старт:
1. Скопируйте `inventory.example.yml` в `inventory.yml`
2. Обновите IP адрес и пользователя в `inventory.yml`
3. Проверьте подключение: `./check_connection.sh`
4. Запустите: `ansible-playbook playbook.yml`

## Автоматическое развертывание через GitLab CI/CD

Проект настроен для автоматического развертывания через GitLab CI/CD.

### Настройка

1. **Настройте переменные CI/CD** в GitLab:
   - Settings → CI/CD → Variables
   - См. подробную инструкцию: [.gitlab-ci-variables.md](.gitlab-ci-variables.md)

2. **Обязательные переменные:**
   - `ANSIBLE_HOST` - IP адрес целевого хоста
   - `ANSIBLE_USER` - пользователь для SSH
   - `SSH_PRIVATE_KEY` - приватный SSH ключ (рекомендуется)
   - Или `ANSIBLE_SSH_PASS` и `ANSIBLE_BECOME_PASS` (менее безопасно)

### Использование

- **Проверка синтаксиса** - автоматически при создании MR или push в main/master/develop
- **Проверка подключения** - ручной запуск job `test-connection`
- **Развертывание в staging** - ручной запуск job `deploy-staging` (ветки develop/staging)
- **Развертывание в production** - ручной запуск job `deploy-production` (ветки main/master)

### Этапы pipeline

1. **validate** - проверка синтаксиса playbook
2. **deploy** - развертывание на целевые хосты

Все job развертывания запускаются вручную (`when: manual`) для безопасности.

## Проверка результата

После выполнения playbook проверьте статус:

```bash
# На удаленном хосте
docker ps
docker compose -f /opt/nginx-compose/docker-compose.yml ps
curl http://localhost
```

## Лицензия

MIT

## Автор

Denis



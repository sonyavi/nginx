# Инструкция по запуску playbook

## Предварительные требования

1. Установлен Ansible >= 2.14
2. Установлены зависимости: `ansible-galaxy collection install -r requirements.yml`
3. Права sudo на целевом хосте

## Проверка синтаксиса

```bash
ansible-playbook --syntax-check playbook.yml
```

## Запуск в режиме проверки (dry-run)

```bash
ansible-playbook --check --diff playbook.yml --ask-become-pass
```

## Полный запуск playbook

### На localhost (текущая машина)

```bash
ansible-playbook playbook.yml --ask-become-pass
```

### На удаленном хосте

1. Обновите `inventory.yml`:
```yaml
all:
  hosts:
    your-server:
      ansible_host: 192.168.1.10
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

2. Запустите:
```bash
ansible-playbook playbook.yml --ask-become-pass
```

### С использованием SSH ключа без пароля

Если настроен NOPASSWD для sudo или используется SSH ключ:
```bash
ansible-playbook playbook.yml
```

## Переопределение переменных

```bash
ansible-playbook playbook.yml \
  -e "nginx_compose_host_port=8080" \
  -e "docker_engine_docker_users=['your-user']" \
  --ask-become-pass
```

## Проверка результата

После выполнения проверьте:

```bash
# Проверка Docker
docker --version
docker compose version

# Проверка nginx контейнера
docker ps | grep nginx
docker compose -f /opt/nginx-compose/docker-compose.yml ps

# Проверка доступности nginx
curl http://localhost
```

## Устранение проблем

### Проблема с паролем sudo

Если требуется пароль, используйте `--ask-become-pass`:
```bash
ansible-playbook playbook.yml --ask-become-pass
```

### Проблема с временными директориями

Если возникают ошибки с временными директориями, проверьте права:
```bash
sudo mkdir -p /tmp/.ansible-tmp
sudo chmod 777 /tmp/.ansible-tmp
```

### Проблема с коллекциями

Установите зависимости:
```bash
ansible-galaxy collection install -r requirements.yml
```


# Развертывание nginx на виртуальной машине

## Подготовка виртуальной машины

### Требования к VM:
- **ОС**: Ubuntu 22.04 (jammy) / 24.04 (noble) или Debian 11 (bullseye) / 12 (bookworm)
- **Минимум**: 1 CPU, 512MB RAM, 5GB диска
- **Сеть**: Доступ по SSH из вашей машины
- **Права**: Пользователь с правами sudo

### Настройка SSH доступа

#### Вариант 1: SSH ключ (рекомендуется)

1. Создайте SSH ключ (если еще нет):
```bash
ssh-keygen -t rsa -b 4096 -C "ansible@nginx"
```

2. Скопируйте ключ на виртуальную машину:
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@<IP_VM>
```

3. Проверьте подключение:
```bash
ssh ubuntu@<IP_VM>
```

#### Вариант 2: Пароль (менее безопасно)

Убедитесь, что на VM включен SSH доступ по паролю.

## Настройка inventory

1. Скопируйте пример inventory:
```bash
cp inventory.example.yml inventory.yml
```

2. Отредактируйте `inventory.yml` с данными вашей VM:
```yaml
all:
  hosts:
    vm-nginx:
      ansible_host: 192.168.1.100  # IP вашей VM
      ansible_user: ubuntu          # Пользователь на VM
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

## Проверка подключения

Проверьте, что Ansible может подключиться к VM:

```bash
ansible all -i inventory.yml -m ping
```

Если используется пароль вместо ключа:
```bash
ansible all -i inventory.yml -m ping --ask-pass --ask-become-pass
```

## Развертывание

### 1. Установка зависимостей (на вашей машине)

```bash
ansible-galaxy collection install -r requirements.yml
```

### 2. Запуск playbook

#### С SSH ключом:
```bash
ansible-playbook playbook.yml
```

#### С паролем:
```bash
ansible-playbook playbook.yml --ask-pass --ask-become-pass
```

### 3. С переопределением переменных:

```bash
ansible-playbook playbook.yml \
  -e "nginx_compose_host_port=8080" \
  -e "docker_engine_docker_users=['ubuntu']"
```

## Проверка результата

### На вашей машине:
```bash
# Проверка через Ansible
ansible all -i inventory.yml -m shell -a "docker ps"
ansible all -i inventory.yml -m shell -a "curl -I http://localhost"

# Или напрямую по SSH
ssh ubuntu@<IP_VM> "docker ps"
ssh ubuntu@<IP_VM> "curl -I http://localhost"
```

### На виртуальной машине:
```bash
# Проверка Docker
docker --version
docker compose version

# Проверка контейнеров
docker ps
docker compose -f /opt/nginx-compose/docker-compose.yml ps

# Проверка nginx
curl http://localhost
curl -I http://localhost
```

## Доступ к nginx

После развертывания nginx будет доступен на:
- **Порт по умолчанию**: `http://<IP_VM>:80`
- **Или кастомный порт**: `http://<IP_VM>:<nginx_compose_host_port>`

Откройте в браузере или проверьте:
```bash
curl http://<IP_VM>
```

## Устранение проблем

### Проблема: "Host key verification failed"

Добавьте VM в known_hosts или отключите проверку (в `ansible.cfg` уже установлено `host_key_checking = False`).

### Проблема: "Permission denied (publickey)"

1. Проверьте SSH ключ:
```bash
ssh -v ubuntu@<IP_VM>
```

2. Убедитесь, что ключ добавлен в `inventory.yml`:
```yaml
ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Проблема: "sudo: a password is required"

Используйте `--ask-become-pass`:
```bash
ansible-playbook playbook.yml --ask-become-pass
```

Или настройте NOPASSWD на VM:
```bash
# На VM выполните:
sudo visudo
# Добавьте строку:
ubuntu ALL=(ALL) NOPASSWD: ALL
```

### Проблема: "Failed to connect to host"

1. Проверьте доступность VM:
```bash
ping <IP_VM>
```

2. Проверьте SSH:
```bash
ssh ubuntu@<IP_VM>
```

3. Проверьте firewall на VM:
```bash
# На VM
sudo ufw status
sudo ufw allow 22/tcp  # SSH
sudo ufw allow 80/tcp  # nginx
```

## Примеры для разных провайдеров VM

### VirtualBox/VMware
- Обычно используется NAT или Bridged сеть
- IP можно узнать через `ip addr` на VM

### AWS EC2
```yaml
vm-nginx:
  ansible_host: ec2-xx-xx-xx-xx.compute-1.amazonaws.com
  ansible_user: ubuntu
  ansible_ssh_private_key_file: ~/.ssh/aws-key.pem
```

### DigitalOcean
```yaml
vm-nginx:
  ansible_host: <droplet-ip>
  ansible_user: root
  ansible_ssh_private_key_file: ~/.ssh/do-key
```

### Vagrant
```yaml
vm-nginx:
  ansible_host: 127.0.0.1
  ansible_port: 2222
  ansible_user: vagrant
  ansible_ssh_private_key_file: ~/.vagrant.d/insecure_private_key
```


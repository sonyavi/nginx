# Управление inventory.yml с переменными окружения

## Проблема безопасности

Хранение паролей в `inventory.yml` в репозитории - это **небезопасно**! 

## Решение: использование переменных окружения

### Вариант 1: Автоматическая генерация (рекомендуется)

Используйте скрипт `generate-inventory.sh` для создания `inventory.yml` из переменных окружения:

```bash
# Установите переменные окружения
export ANSIBLE_HOST=91.108.243.32
export ANSIBLE_USER=root
export ANSIBLE_SSH_PASS="your_password"
export ANSIBLE_BECOME_PASS="your_password"

# Сгенерируйте inventory.yml
./generate-inventory.sh
```

### Вариант 2: Использование SSH ключа

```bash
export ANSIBLE_HOST=91.108.243.32
export ANSIBLE_USER=root
export SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"

./generate-inventory.sh
```

### Вариант 3: Использование .env файла

Создайте файл `.env` (добавлен в .gitignore):

```bash
# .env
ANSIBLE_HOST=91.108.243.32
ANSIBLE_USER=root
ANSIBLE_SSH_PASS=your_password
ANSIBLE_BECOME_PASS=your_password
```

Затем:

```bash
source .env
./generate-inventory.sh
```

### Вариант 4: Использование GitLab CI/CD переменных

В GitLab CI/CD переменные уже настроены, и `inventory.ci.yml` создается автоматически из них.

## Локальное использование

### Быстрый старт:

1. **Установите переменные окружения:**
   ```bash
   export ANSIBLE_HOST=91.108.243.32
   export ANSIBLE_USER=root
   export ANSIBLE_SSH_PASS="your_password"
   export ANSIBLE_BECOME_PASS="your_password"
   ```

2. **Сгенерируйте inventory:**
   ```bash
   ./generate-inventory.sh
   ```

3. **Запустите playbook:**
   ```bash
   ansible-playbook playbook.yml
   ```

### Постоянная настройка (в ~/.bashrc или ~/.zshrc):

```bash
# Добавьте в ~/.bashrc или ~/.zshrc
export ANSIBLE_HOST=91.108.243.32
export ANSIBLE_USER=root
export ANSIBLE_SSH_PASS="your_password"
export ANSIBLE_BECOME_PASS="your_password"
```

Затем:
```bash
source ~/.bashrc  # или source ~/.zshrc
./generate-inventory.sh
```

## Безопасность

### ✅ Что делать:

1. **Добавьте `inventory.yml` в `.gitignore`** (уже добавлено)
2. **Используйте переменные окружения** вместо хардкода паролей
3. **Используйте SSH ключи** вместо паролей (более безопасно)
4. **Используйте ansible-vault** для шифрования чувствительных данных

### ❌ Чего НЕ делать:

1. **НЕ коммитьте** `inventory.yml` с паролями в репозиторий
2. **НЕ храните** пароли в открытом виде
3. **НЕ делитесь** паролями через незащищенные каналы

## Проверка

После генерации inventory проверьте:

```bash
# Проверка синтаксиса
ansible-inventory -i inventory.yml --list

# Проверка подключения
ansible all -i inventory.yml -m ping
```

## Troubleshooting

### Ошибка: "inventory.yml not found"

**Решение:** Запустите `./generate-inventory.sh` для создания файла

### Ошибка: "ANSIBLE_HOST is not set"

**Решение:** Установите переменные окружения:
```bash
export ANSIBLE_HOST=your_host
export ANSIBLE_USER=your_user
```

### Ошибка: "Permission denied"

**Решение:** Убедитесь, что скрипт исполняемый:
```bash
chmod +x generate-inventory.sh
```


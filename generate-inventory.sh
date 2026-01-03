#!/bin/bash
# Скрипт для генерации inventory.yml из переменных окружения
# Использование: ./generate-inventory.sh

set -e

INVENTORY_FILE="inventory.yml"

# Значения по умолчанию (можно переопределить через переменные окружения)
ANSIBLE_HOST="${ANSIBLE_HOST:-91.108.243.32}"
ANSIBLE_USER="${ANSIBLE_USER:-root}"
ANSIBLE_HOST_NAME="${ANSIBLE_HOST_NAME:-vm-nginx}"

echo "🔧 Генерация inventory.yml из переменных окружения..."

# Проверка обязательных переменных
if [ -z "$ANSIBLE_HOST" ] || [ -z "$ANSIBLE_USER" ]; then
    echo "❌ Ошибка: ANSIBLE_HOST и ANSIBLE_USER должны быть установлены"
    exit 1
fi

# Создание inventory файла
{
    echo "---"
    echo "all:"
    echo "  hosts:"
    echo "    ${ANSIBLE_HOST_NAME}:"
    echo "      ansible_host: ${ANSIBLE_HOST}"
    echo "      ansible_user: ${ANSIBLE_USER}"
    
    # SSH ключ (приоритет)
    if [ -n "$SSH_PRIVATE_KEY" ]; then
        echo "      ansible_ssh_private_key_file: ~/.ssh/id_rsa"
    # Или SSH пароль
    elif [ -n "$ANSIBLE_SSH_PASS" ]; then
        echo "      ansible_ssh_pass: \"${ANSIBLE_SSH_PASS}\""
    fi
    
    # Sudo пароль
    if [ -n "$ANSIBLE_BECOME_PASS" ]; then
        echo "      ansible_become_pass: \"${ANSIBLE_BECOME_PASS}\""
    fi
} > "$INVENTORY_FILE"

echo "✅ Inventory файл создан: $INVENTORY_FILE"
echo ""
echo "📋 Содержимое:"
cat "$INVENTORY_FILE"
echo ""

# Предупреждение о безопасности
if grep -q "ansible_ssh_pass\|ansible_become_pass" "$INVENTORY_FILE"; then
    echo ""
    echo "⚠️  ВНИМАНИЕ: В inventory.yml содержатся пароли!"
    echo "   ✅ Файл добавлен в .gitignore и не будет закоммичен"
    if git ls-files --error-unmatch "$INVENTORY_FILE" >/dev/null 2>&1; then
        echo "   ⚠️  Файл был закоммичен ранее! Удалите его из истории:"
        echo "      git rm --cached inventory.yml"
        echo "      git commit -m 'Remove inventory.yml from repository'"
    fi
fi


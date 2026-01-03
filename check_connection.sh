#!/bin/bash
# Скрипт для проверки подключения к виртуальной машине

echo "🔍 Проверка подключения к виртуальной машине..."
echo ""

# Проверка наличия inventory
if [ ! -f "inventory.yml" ]; then
    echo "❌ Файл inventory.yml не найден!"
    echo "💡 Скопируйте inventory.example.yml в inventory.yml и обновите параметры"
    exit 1
fi

# Проверка подключения
echo "📡 Тестирование SSH подключения..."
ansible all -i inventory.yml -m ping

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Подключение успешно!"
    echo ""
    echo "📋 Информация о системе:"
    ansible all -i inventory.yml -m setup -a "filter=ansible_distribution*" | grep -E "ansible_distribution|ansible_distribution_version"
    echo ""
    echo "🚀 Готово к развертыванию! Запустите:"
    echo "   ansible-playbook playbook.yml"
else
    echo ""
    echo "❌ Ошибка подключения!"
    echo ""
    echo "💡 Возможные решения:"
    echo "   1. Проверьте IP адрес и пользователя в inventory.yml"
    echo "   2. Убедитесь, что SSH доступен: ssh user@ip"
    echo "   3. Если используется пароль, запустите:"
    echo "      ansible all -i inventory.yml -m ping --ask-pass"
    exit 1
fi


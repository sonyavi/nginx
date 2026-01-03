# Безопасность и управление паролями

## ⚠️ Важно: Пароли не должны быть в репозитории!

Файл `inventory.yml` добавлен в `.gitignore` и **не должен** содержать пароли в открытом виде.

## Текущее состояние

✅ **Пароли удалены** из `inventory.yml`  
✅ **Файл в .gitignore** - не будет закоммичен  
✅ **Используйте переменные окружения** для паролей

## Если inventory.yml был закоммичен ранее

Если файл с паролями уже был закоммичен в репозиторий, выполните:

```bash
# 1. Удалите файл из индекса Git (но оставьте локально)
git rm --cached inventory.yml

# 2. Закоммитьте удаление
git commit -m "Remove inventory.yml from repository (security)"

# 3. Убедитесь, что файл в .gitignore
echo "inventory.yml" >> .gitignore

# 4. Запушите изменения
git push
```

**⚠️ ВАЖНО:** Если пароли уже были закоммичены, они останутся в истории Git!  
Для полного удаления используйте `git filter-branch` или `git filter-repo` (требует перезаписи истории).

## Правильное использование

### 1. Используйте generate-inventory.sh

```bash
# Установите переменные окружения
export ANSIBLE_HOST=91.108.243.32
export ANSIBLE_USER=root
export ANSIBLE_SSH_PASS="your_password"
export ANSIBLE_BECOME_PASS="your_password"

# Сгенерируйте inventory.yml
./generate-inventory.sh
```

### 2. Используйте SSH ключи (рекомендуется)

```bash
export ANSIBLE_HOST=91.108.243.32
export ANSIBLE_USER=root
export SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"

./generate-inventory.sh
```

### 3. Используйте .env файл

Создайте `.env` (уже в .gitignore):

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

## Проверка безопасности

Проверьте, что пароли не в репозитории:

```bash
# Проверка, что inventory.yml в .gitignore
grep inventory.yml .gitignore

# Проверка, что файл не отслеживается Git
git ls-files inventory.yml

# Если файл отслеживается, удалите его:
git rm --cached inventory.yml
```

## Рекомендации

1. ✅ **Используйте SSH ключи** вместо паролей
2. ✅ **Храните пароли в переменных окружения** или секретных менеджерах
3. ✅ **Используйте ansible-vault** для шифрования чувствительных данных
4. ✅ **Регулярно ротируйте** пароли и ключи
5. ❌ **НЕ коммитьте** пароли в репозиторий
6. ❌ **НЕ делитесь** паролями через незащищенные каналы


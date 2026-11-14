# Lampa Self-Hosted

## MOD

### Удалена авторизация
Удалить файл `source/web/custom_plugins/auth.js`
### Удален прокси подмены ключа Jackett
Удален файл `source/web/custom_plugins/jackett_proxy.js`
Переписан файл для пускания трафика напрямую
```nginx
...
location /jackett/ {
	proxy_pass http://jackett:9117/;
	proxy_set_header Host $http_host;
	proxy_set_header X-Real-IP $remote_addr;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_read_timeout 60;
	proxy_send_timeout 60;
}
...
```
API ключ (`"APIKey": "auto"`) задан `auto` в `data/jackett/config/Jackett/ServerConfig.json`

### Добавлен сервис опроса jacket

[test_rutracker](scripts/test_rutracker.sh)

---

🎬 Полностью самостоятельная версия [Lampa](https://github.com/yumata/lampa) - медиацентра с синхронизацией и Telegram-интеграцией.

## 🌟 Особенности

- ✅ **Автономная сборка** - исходники Lampa клонируются из GitHub при сборке Docker
- ✅ **Hot-reload плагинов** - редактируй плагины без пересборки контейнера
- ✅ **Telegram Bot** - управление устройствами через бота
- ✅ **Синхронизация** - закладки, профили, история просмотров
- ✅ **Sync Player** - совместный просмотр с друзьями в реальном времени
- ✅ **HTTPS** - автоматические сертификаты Let's Encrypt
- ✅ **Dart Backend** - быстрый и надёжный сервер на Dart Frog

## 📁 Структура проекта

```
lampa_selfhosted/
├── source/                 # Исходники (git-tracked)
│   ├── web/                # Frontend сборка
│   │   ├── Dockerfile
│   │   ├── patches.json    # Патчи для self-hosted
│   │   ├── entrypoint.sh   # Генерация манифеста плагинов
│   │   └── custom_plugins/ # Встроенные плагины
│   │       ├── modification.js
│   │       ├── auth.js
│   │       └── ...
│   │
│   ├── server/             # Backend на Dart Frog
│   │   ├── main.dart
│   │   ├── routes/         # API endpoints
│   │   └── lib/            # Модели и сервисы
│   │
│   ├── nginx/              # Шаблоны конфигов nginx
│   └── jackett/            # Шаблон конфига Jackett
│
├── data/                   # Пользовательские данные (.gitignore)
│   ├── plugins/            # Кастомные плагины (приоритет над builtin!)
│   ├── nginx/              # Сгенерированный конфиг nginx
│   ├── database/           # SQLite база данных
│   ├── jackett/            # Конфиг и индексеры Jackett
│   ├── torrserver/         # Кеш и конфиг TorrServer
│   ├── transcoding/        # Кеш транскодинга
│   └── certs/              # SSL сертификаты
│
└── docker-compose.yml      # Оркестрация
```

## 🔌 Система плагинов

Плагины поддерживают **runtime overlay** - можно добавлять свои плагины и переопределять встроенные без пересборки:

1. **Встроенные плагины** (`source/web/custom_plugins/`) - поставляются с проектом
2. **Пользовательские плагины** (`data/plugins/`) - ваши кастомные плагины

### Добавить свой плагин

```bash
# Скопируйте свой плагин в data/plugins/
cp my_plugin.js data/plugins/

# Перезапустите frontend
docker compose restart lampa-frontend
```

### Переопределить встроенный плагин

Создайте файл с таким же именем в `data/plugins/`:
```bash
# Например, чтобы заменить auth.js своей версией:
cp my_custom_auth.js data/plugins/auth.js

# Перезапустите frontend
docker compose restart lampa-frontend
```

## 🚀 Быстрый старт

### 1. Клонируйте репозиторий

```bash
git clone https://github.com/serezhia/lampa_selfhosted.git
cd lampa_selfhosted
```

### 2. Создайте Telegram бота

1. Напишите [@BotFather](https://t.me/BotFather)
2. Отправьте `/newbot` и следуйте инструкциям
3. Скопируйте токен бота

### 3. Настройте окружение

Создайте файл `.env`:
```env
TELEGRAM_BOT_TOKEN=your_bot_token_here
GITHUB_REPOSITORY_OWNER=serezhia
```

### 4. Настройте домен

Отредактируйте [source/web/patches.json](source/web/patches.json):
```json
{
  "config": {
    "SELF_HOSTED_DOMAIN": "your-domain.com",
    "CUB_API_DOMAIN": "cub.rip"
  }
}
```

Конфиг nginx генерируется автоматически при установке.

### 5. Запустите

```bash
# Сборка и запуск
docker-compose up -d --build

# Проверка логов
docker-compose logs -f
```

### 6. Настройте HTTPS (опционально)

```bash
# Выполните скрипт для Let's Encrypt
./init-letsencrypt.sh
```

## 🔧 Разработка

### Редактирование плагинов

Плагины в `data/plugins/` доступны без пересборки - добавь файл и перезапусти контейнер!

```bash
# 1. Добавь свой плагин
cp my_plugin.js data/plugins/

# 2. Перезапусти frontend
docker compose restart lampa-frontend
```

### Редактирование встроенных плагинов

Встроенные плагины в `source/web/custom_plugins/` требуют пересборки:

```bash
# 1. Отредактируй плагин
nano source/web/custom_plugins/auth.js

# 2. Пересобери
docker compose up -d --build lampa-frontend
```

### Обновление Lampa

```bash
# Пересобрать с последней версией из GitHub
docker-compose build --no-cache lampa-frontend
docker-compose up -d lampa-frontend
```

## 📚 Документация

- [source/web/README.md](source/web/README.md) - сборка фронтенда, патчи, плагины
- [data/README.md](data/README.md) - структура пользовательских данных

## 🤖 Telegram Bot

Команды бота:
- `/start` - Регистрация
- `/add` - Сгенерировать код для привязки устройства
- `/devices` - Список устройств
- `/remove` - Удалить устройство

## 🏗️ Архитектура

### Почему так?

**Старый подход** (lampa-source в репо):
- ❌ Гигабайты исходников в Git
- ❌ Сложно обновлять
- ❌ Изменения нужно перебазировать при обновлении

**Новый подход** (клонирование при сборке):
- ✅ Репозиторий содержит только конфигурацию
- ✅ Обновление = пересборка образа
- ✅ Патчи применяются автоматически
- ✅ Hot-reload для плагинов

### Как работает сборка

1. `Dockerfile` клонирует `yumata/lampa-source` из GitHub
2. Применяет патчи из `patches.json`
3. Собирает через `gulp pack_github`
4. Результат упаковывается в nginx образ
5. Кастомные плагины монтируются через volume

## 🔒 Безопасность

- Аутентификация через Telegram
- 6-значные коды (5 минут TTL)
- HTTPS через Let's Encrypt
- Безопасное хранение данных в `database.json`

## 📝 Лицензия

MIT

## 🙏 Благодарности

- [Lampa](https://github.com/yumata/lampa) - оригинальный проект
- [Dart Frog](https://dartfrog.vgv.dev/) - backend фреймворк

## 📧 Контакты

Проблемы? Создайте [Issue](https://github.com/serezhia/lampa_selfhosted/issues)

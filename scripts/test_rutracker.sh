#!/bin/sh

JACKETT_URL="http://jackett:9117"
PASSWORD="auto"
INDEXER_ID="rutracker" # системное имя трекера

# Временный файл для хранения сессионной куки
COOKIE_FILE=$(mktemp)

# 1. Получаем сессионную куку (авторизация)
curl -s -c "$COOKIE_FILE" \
  -X POST "$JACKETT_URL/UI/Dashboard" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "password=$PASSWORD" > /dev/null

# 2. Отправляем POST-запрос на тестирование трекера (аналог кнопки Test)
RESPONSE=$(curl -s -w "\n%{http_code}" -b "$COOKIE_FILE" \
  -X POST "$JACKETT_URL/api/v2.0/indexers/$INDEXER_ID/test")

# Удаляем временный файл с кукой
rm -f "$COOKIE_FILE"

# Разделяем тело ответа и HTTP-код
HTTP_BODY=$(echo "$RESPONSE" | sed '$d')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 204 ]; then
  echo "Успех: трекер $INDEXER_ID прошел проверку (HTTP $HTTP_CODE)."
  echo "Ждем 1000s"
  sleep 1000s
else
  echo "Ошибка проверки $INDEXER_ID (HTTP $HTTP_CODE):"
  echo "Ждем 10s"
  sleep 10s
fi


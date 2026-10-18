#!/usr/bin/env bash
# Ежедневный отчёт по логам сайта pavel.test
set -euo pipefail

LOG=/var/log/nginx/homelab.access.log
ENV_FILE=/etc/homelab/telegram.env
TODAY=$(LC_ALL=C date +%d/%b/%Y)

# Берём из лога только сегодняшние строки
LINES=$(grep -F "[$TODAY" "$LOG" || true)

if [[ -z "$LINES" ]]; then
    REPORT="📊 pavel.test, $TODAY: запросов не было"
else
    TOTAL=$(echo "$LINES" | wc -l)
    UNIQUE=$(echo "$LINES" | awk '{print $1}' | sort -u | wc -l)
    ERRORS=$(echo "$LINES" | awk '$9 >= 400' | wc -l)
    CODES=$(echo "$LINES" | awk '{print $9}' | sort | uniq -c | sort -rn)
    TOP_IPS=$(echo "$LINES" | awk '{print $1}' | sort | uniq -c | sort -rn | head -5)
    TOP_URLS=$(echo "$LINES" | awk '{print $7}' | sort | uniq -c | sort -rn | head -5)

    REPORT="📊 Отчёт pavel.test за $TODAY
Всего запросов: $TOTAL
Уникальных IP: $UNIQUE
Ошибок (4xx/5xx): $ERRORS

Коды ответов:
$CODES

Топ IP:
$TOP_IPS

Топ страниц:
$TOP_URLS"
fi

# Если настроек Telegram нет, просто выводим отчёт на экран
if [[ ! -f "$ENV_FILE" ]]; then
    echo "$REPORT"
    exit 0
fi

source "$ENV_FILE"
curl -s -m 20 "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
    -d chat_id="$TG_CHAT_ID" \
    --data-urlencode text="$REPORT" > /dev/null
echo "Отчёт отправлен в Telegram"

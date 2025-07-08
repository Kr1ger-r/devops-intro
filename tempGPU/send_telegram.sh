#!/bin/bash

BOT_TOKEN="8054698918:AAFaK54y31Vj0GERBvppmikFrxv_ZKpdsGw"
CHAT_ID="467747472"
MESSAGE="$1"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
     -d chat_id="${CHAT_ID}" \
     -d text="${MESSAGE}" > /dev/null
#!/bin/bash

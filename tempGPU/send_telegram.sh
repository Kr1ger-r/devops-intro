#!/bin/bash

BOT_TOKEN="8025832918:...."
CHAT_ID="467..."
MESSAGE="$1"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
     -d chat_id="${CHAT_ID}" \
     -d text="${MESSAGE}" > /dev/null
#!/bin/bash

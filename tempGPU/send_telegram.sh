#!/bin/bash

BOT_TOKEN="8054698918:...."
CHAT_ID="46774..."
MESSAGE="$1"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
     -d chat_id="${CHAT_ID}" \
     -d text="${MESSAGE}" > /dev/null
#!/bin/bash

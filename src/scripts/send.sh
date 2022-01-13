echo -e "${_body}"
echo -e "---"

echo -e "curl -s -o /dev/null -w '%{http_code}\n' -X POST -H X-ChatWorkToken: ${CHATWORK_TOKEN} \
    -d body=${_body}&self_unread=${IS_UNREAD} https://api.chatwork.com/${VER}/rooms/${ROOMID}/messages"

RESULT=$(curl -s -o /dev/null -w '%{http_code}\n' -X POST -H "X-ChatWorkToken: ${CHATWORK_TOKEN}" \
    -d "body=${_body}&self_unread=${IS_UNREAD}" "https://api.chatwork.com/${VER}/rooms/${ROOMID}/messages")

echo "http_code=${RESULT}"
[ "200" = "${RESULT}" ] || exit 1
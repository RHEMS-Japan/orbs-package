TIME=$(date '+%Y-%m-%d-%H-%M-%S')

. "/tmp/RHEMS_JOB_STATUS"

${STATUS} || STATUS=false

### CHECK ENV
[ "${TOKEN::1}" == '$' ] && TOKEN=`eval echo ${TOKEN}`
[ "${ORGANIZATION::1}" == '$' ] && ORGANIZATION=`eval echo ${ORGANIZATION}`
[ "${REPO::1}" == '$' ] && REPO=`eval echo ${REPO}`
[ "${BRANCH::1}" == '$' ] && BRANCH=`eval echo ${BRANCH}`
[ "${TEXT::1}" == '$' ] && TEXT=`eval echo ${TEXT}`
[ "${IS_ERROR_TEXT::1}" == '$' ] && IS_ERROR_TEXT=`eval echo ${IS_ERROR_TEXT}`
[ "${APP::1}" == '$' ] && APP=`eval echo ${APP}`

${STATUS} || ${TEXT} || ${IS_ERROR_TEXT} || TEXT=${IS_ERROR_TEXT}

########### debug
check_debug () {
echo "--- debug ---"
cat << EOS
{
"api_token": "${TOKEN}",
"organization": "${ORGANIZATION}",
"repo": "${REPO}",
"app": "${APP}",
"branch": "${BRANCH}",
"status": ${STATUS},
`[ -n "${TEXT}" ] && \
cat << EOF
"txt": "${TEXT}",
EOF`
`[ -n "${COLOR}" ] && \
cat << EOF
"color": "${COLOR}",
EOF`
"update": "${TIME}"
}
EOS
env
echo "--- debug ---"
########### debug
}

post_to_badgeserver () {
echo "--- main ---"
RESPONSE=$(curl -w '%{http_code}\n' -X POST -H "Content-Type: application/json" \
https://badges.rhems-japan.com/api-update-badge \
-d @- <<EOS
{
"api_token": "${TOKEN}",
"organization": "${ORGANIZATION}",
"repo": "${REPO}",
"app": "${APP}",
"branch": "${BRANCH}",
"status": ${STATUS},
`[ -n "${TEXT}" ] && \
cat << EOF
"txt": "${TEXT}",
EOF`
`[ -n "${COLOR}" ] && \
cat << EOF
"color": "${COLOR}",
EOF`
"update": "${TIME}"
}
EOS
)

RESPONSE_JSON=$(echo $RESPONSE | awk -F "}" '{print $1}')"}"
HTTP_RESPONSE=$(echo $RESPONSE | awk -F "}" '{print $2}')
echo http_code=$HTTP_RESPONSE
if [ ${HTTP_RESPONSE} -ne '200' ]; then
  # Responses other than 200 end with an error.
  exit 1
else
  echo -e $RESPONSE_JSON | jq
fi
}

################## ---- main
check_debug
post_to_badgeserver
# if [ ! -n "${TEXT}" ]; then
#    post_to_badgeserver
# else
#   ${STATUS} && post_to_badgeserver
# fi

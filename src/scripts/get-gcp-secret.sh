_secret_name=$(eval echo "$SECRET_NAME")

_latest_ver=$(gcloud secrets versions list "${_secret_name}" --limit=1 | awk '{print $1}' | sed -n 2p)
echo LATEST_VER = "${_latest_ver}"

gcloud secrets versions access "${_latest_ver}" \
  --secret="${_secret_name}" --format='get(payload.data)' |
  tr '_-' '/+' |
  base64 -d >> "./${OUTPUT_PATH}"
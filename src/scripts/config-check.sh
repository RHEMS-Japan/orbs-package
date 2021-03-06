now_md5=$(md5sum < .circleci/config.yml)

set -eu
set -o pipefail

_basepath=$(eval echo "${CONFIG_DIR}")
_targets="${_basepath}/bases|${_basepath}/commands|${_basepath}/jobs|${_basepath}/workflows"

mkdir ./cmd
wget https://github.com/suzuki-shunsuke/circleci-config-merge/releases/download/v1.1.1/circleci-config-merge_1.1.1_linux_amd64.tar.gz -O - | tar zxvf - -C ./cmd
_cmd="./cmd/circleci-config-merge"
remerge_md5=$(git ls-files | grep -E "${_targets}" | xargs "${_cmd}" merge | md5sum)

echo "${now_md5}"
echo "${remerge_md5}"
if [ ! "${now_md5}" = "${remerge_md5}" ]; then
  echo "You forgot circleci-config-merge!"
  exit 1
fi

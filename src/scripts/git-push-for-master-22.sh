echo "===============================================================" 
echo "============== This command is for ubuntu22.04. ==============="
echo "===============================================================" 

echo "check ssh config ----------------------------------------------"
if [ -f ~/.ssh/config ]; then
  cat ~/.ssh/config
fi
echo "---------------------------------------------------------------"

function use-key() {
  # $1 : ${MASTER_FINGER_PRINT}
  _key=$(eval echo $1 | sed -e 's/://g')
  export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_${_key}"
}

module_name=$(eval echo ${MODULE_NAME})
commit_message=$(eval echo ${COMMIT_MESSAGE})
if [ "${commit_message}" = "[skip ci] update submodule" ]; then
  commit_message="${commit_message}: ${module_name}"
fi

use-key ${MASTER_FINGER_PRINT}
git branch --set-upstream-to=origin/${CIRCLE_BRANCH} ${CIRCLE_BRANCH}
git pull --no-edit
git commit -a -m "${commit_message}" || true

set +e
git push -u origin ${CIRCLE_BRANCH}
RESULT=$?
echo "RESULT = ${RESULT}"
if [ $RESULT -eq 128 ]; then
  echo 'Please make sure you have the correct access rights and the repository exists.'
  set -e
  exit 1
elif [ $RESULT -ne 0 ]; then
  echo "Failed. The git push could not be completed successfully due to the timing. Please try again."
  set -e
  exit 1
else
  echo 'Success'
fi

# reset config
rm -rf ~/.ssh/config

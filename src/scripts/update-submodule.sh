function check_for_module() {
  if [ -e ".git/modules/$1" ]; then
      return true
  fi
}

if [ -n ${MODULE_NAME} ]; then
  module_name=$(eval echo ${MODULE_NAME})

  commit_message=$(eval echo ${COMMIT_MESSAGE})
  if [ "${commit_message}" = "[skip ci] update submodule" ]; then
    commit_message="${commit_message}: ${module_name}"
  fi

  _key=$(eval echo ${SUBM_FINGER_PRINT} | sed -e 's/://g')
  export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_${_key}"
  git config --global user.email "submodule.updater@rhems-japan.co.jp"
  git config --global user.name "submodule-updater"

  if(check_for_module ${MODULE_NAME}); then
    echo -e "[OK] Settings already exist in module.\n"
  else
    echo -e "[NG] No setting in module.\n"
    git submodule add --quiet --force -b ${CIRCLE_BRANCH} ${MODULE_NAME}
  fi

  git submodule update --init --remote --recursive ${module_name}
  git status

  git checkout ${CIRCLE_BRANCH}
  _key=$(eval echo ${MASTER_FINGER_PRINT} | sed -e 's/://g')
  export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_${_key}"
  git branch --set-upstream-to=origin/${CIRCLE_BRANCH} ${CIRCLE_BRANCH}
  git pull
  git commit -a -m "${commit_message}" || true
  git push -u origin ${CIRCLE_BRANCH}
  else
  echo "target not found."
fi

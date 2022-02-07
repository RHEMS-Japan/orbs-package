if [ -n ${MODULE_NAME} ]; then
  module_name=$(eval echo ${MODULE_NAME})
  commit_message=$(eval echo ${COMMIT_MESSAGE})
  if [ "${commit_message}" = "[skip ci] update submodule" ]; then
    commit_message="${commit_message}: ${module_name}"
  fi
  reponame=$(echo $CIRCLE_REPOSITORY_URL | awk -F "/" '{ print $NF }' | awk -F "." '{ print $(NF-1) }')
  submodule_url=$(echo ${CIRCLE_REPOSITORY_URL} | sed "s/${reponame}/${module_name}/")
  _key=$(eval echo ${SUBM_FINGER_PRINT} | sed -e 's/://g')
  export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_${_key}"
  git config --global user.email "submodule.updater@rhems-japan.co.jp"
  git config --global user.name "submodule-updater"

  # .gitmodulesが存在したら
  if [ -e ".gitmodules" ]; then
    echo -e "already exists .gitmodule\n"
    # pathsにpathを全て取り込む
    paths=$(echo $(grep "path=*" .gitmodules | awk '{print $3}' ))
    # 指定のモジュール名が存在するか
    if [[ $paths =~ $module_name ]]; then
      # 指定のモジュール名のpathが何行目か
      N=$(grep -n "path = $module_name" .gitmodules | sed -e 's/:.*//g')
      # 指定のモジュールのブランチ名の取得
      branch_name=$(awk "NR==$N+2" .gitmodules | awk '{print $3}')
      echo $branch_name
    else
      echo -e "no setting in .gitmodule\n"
      git submodule add --quiet --force -b ${CIRCLE_BRANCH} ${submodule_url}
    fi
  # .gitmodulesが存在しなかったら
  else
    echo -e "no exists .gitmodule\n"
    git submodule add --quiet --force -b ${CIRCLE_BRANCH} ${submodule_url}
  fi

  git submodule sync
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

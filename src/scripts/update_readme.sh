update_readme () {
  echo "== run update_readme =="
  echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
  [ "${BRANCH::1}" == '$' ] && BRANCH=`eval echo ${BRANCH}`
  if [ -n "${BRANCH}" ]; then
    
    git config --global user.email ${GIT_USER_EMAIL}
    git config --global user.name "${GIT_USER_NAME}"
    git checkout ${CIRCLE_BRANCH}
    _key=$(eval echo ${FINGER_PRINT} | sed -e 's/://g')
    export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_${_key}"
    git branch --set-upstream-to=origin/${CIRCLE_BRANCH} ${CIRCLE_BRANCH}
    git pull

    function edit-readme() {
      if [ ${ONLY_DATE} = 0 ]; then
        echo "only_date: false"
        sed -i -e "s#branch=.*\&cised=true.*#branch=${BRANCH}\&cised=true\&update=$(date "+%Y%m%d-%H%M%S")\)#g" ${FILE_PATH}
      else
        echo "only_date: true"
        sed -i -e "s#cised=true.*#cised=true\&update=$(date "+%Y%m%d-%H%M%S")\)#g" ${FILE_PATH}
      fi
    }
    edit-readme
    git add ${FILE_PATH}
    echo "--- run git ---"
    git commit -m "[skip ci] ${FILE_PATH} Update"

    set +e
    git push origin ${CIRCLE_BRANCH}

    RESULT=$?
    echo "RESULT = ${RESULT}"
    if [ $RESULT -ne 0 ]; then
      for i in {2..10};
      do
        echo -e "\n<< Retry $i >>\n"
        sleep 3
        git reset --hard HEAD^
        git pull --no-edit
        edit-readme
        git add ${FILE_PATH}
        git commit -m "[skip ci] ${FILE_PATH} Update"
        git push -u origin ${CIRCLE_BRANCH}
        if [ $? -eq 0 ]; then
          break
        fi
      done
      if [ $i -eq 10 ]; then
        echo -e "\n tried 10 times, but it failed, so it ends. \n"
        set -e
        exit 1
      fi
    else
      echo 'Success'
    fi
  fi
}

${UPDATE_README} && update_readme

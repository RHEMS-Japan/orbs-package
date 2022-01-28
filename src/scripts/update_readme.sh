update_readme () {
  echo "== run update_readme =="
  echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
  [ "${BRANCH::1}" == '$' ] && BRANCH=`eval echo ${BRANCH}`
  if [ -n "${BRANCH}" ]; then
    git config --global user.email ${GIT_USER_EMAIL}
    git config --global user.name "${GIT_USER_NAME}"
    git checkout ${CIRCLE_BRANCH}
    git fetch
    git merge origin/${CIRCLE_BRANCH}

    if [ ${ONLY_DATE} = 0 ]; then
      echo "only_date: false"
      sed -i -e "s#branch=.*\&cised=true.*#branch=${BRANCH}\&cised=true\&update=$(date "+%Y%m%d-%H%M%S")\)#g" ${FILE_PATH}
    else
      echo "only_date: true"
      sed -i -e "s#cised=true.*#cised=true\&update=$(date "+%Y%m%d-%H%M%S")\)#g" ${FILE_PATH}
    fi
    
    git add ${FILE_PATH}
    echo "--- run git ---"
    git commit -m "[skip ci] ${FILE_PATH} Update"
    git push origin ${CIRCLE_BRANCH}
  fi
}

${UPDATE_README} && update_readme

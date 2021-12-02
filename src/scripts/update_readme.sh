update_readme () {
  echo "== run update_readme =="
  if [ -n "${CIRCLE_BRANCH}" ]; then
    sed -i -e "s#branch=.*\&cised=true.*#branch=${CIRCLE_BRANCH}\&cised=true\&update=$(date "+%Y%m%d-%H%M%S")\)#g" ${FILE_PATH}
    git config --global user.email ${GIT_USER_EMAIL}
    git config --global user.name "${GIT_USER_NAME}"
    git add ${FILE_PATH}
    echo "--- run git ---"
    git commit -m "[skip ci] ${FILE_PATH} Update"
    git push origin ${CIRCLE_BRANCH}
  fi
}

${UPDATE_README} && update_readme

echo "check ssh config ----------------------------------------------"
if [ -f ~/.ssh/config ]; then
  cat ~/.ssh/config
fi
echo "---------------------------------------------------------------"

echo ${SUBMODULE_BRANCH}
echo ${MODULE_NAME}
[ -z ${MODULE_NAME} ] && echo "target not found." && exit 1

organization_name=$(eval echo ${ORGANIZATION_NAME})
module_name=$(eval echo ${MODULE_NAME})
commit_message=$(eval echo ${COMMIT_MESSAGE})
if [ "${commit_message}" = "[skip ci] update submodule" ]; then
  commit_message="${commit_message}: ${module_name}"
fi

submodule_url=$(echo ${CIRCLE_REPOSITORY_URL} | sed "s/${CIRCLE_PROJECT_REPONAME}/${module_name}/")

echo $submodule_url
if [[ -n ${ORGANIZATION_NAME} ]]; then
  master_org=$(echo $CIRCLE_REPOSITORY_URL | awk -F "/" '{ print $(NF-1) }' | awk -F ":" '{ print $NF }')
  submodule_url=$(echo ${submodule_url} | sed "s/${master_org}/${organization_name}/")
  echo $submodule_url
fi

function use-key() {
  # $1 : ${SUBM_FINGER_PRINT} or ${MASTER_FINGER_PRINT}
  _key=$(eval echo $1 | sed -e 's/://g')
  export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_${_key}"
}

git config --global user.email "submodule.updater@rhems-japan.co.jp"
git config --global user.name "submodule-updater"

git checkout ${CIRCLE_BRANCH}
function update() {
  use-key ${SUBM_FINGER_PRINT}
  if [ -e ".gitmodules" ]; then
    echo -e "already exists .gitmodule\n"
    paths=$(echo $(grep "path=*" .gitmodules | awk '{print $3}'))
    if [[ $paths =~ $module_name ]]; then
      N=$(grep -n -e "path = ${module_name}"$ .gitmodules | sed -e 's/:.*//g')
      branch_name=$(awk "NR==$N+2" .gitmodules | awk '{print $3}')
      echo "==="
      echo $branch_name
      echo "==="
      if [[ $branch_name != $SUBMODULE_BRANCH ]]; then
        echo -e "change branch of submodule\n"
        git submodule deinit ${module_name}
        git rm ${module_name}
        git submodule add --quiet --force -b ${SUBMODULE_BRANCH} ${submodule_url}
      fi
    else
      echo -e "no setting in .gitmodule\n"
      git submodule add --quiet --force -b ${SUBMODULE_BRANCH} ${submodule_url}
    fi
  else
    echo -e "no exists .gitmodule\n"
    git submodule add --quiet --force -b ${SUBMODULE_BRANCH} ${submodule_url}
  fi
  git submodule sync
  git submodule update --init --remote --recursive ${module_name}
  git status
}

update

use-key ${MASTER_FINGER_PRINT}
git branch --set-upstream-to=origin/${CIRCLE_BRANCH} ${CIRCLE_BRANCH}
git pull --no-edit
git commit -a -m "${commit_message}" || true

set +e
git push -u origin ${CIRCLE_BRANCH}
RESULT=$?
echo "RESULT = ${RESULT}"
if [ $RESULT -ne 0 ]; then
  for i in {2..10};
  do
    echo -e "\n<< Retry $i >>\n"
    sleep 3
    git reset --hard HEAD^
    git pull --no-edit
    update
    use-key ${MASTER_FINGER_PRINT}
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
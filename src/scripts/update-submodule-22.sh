echo "===============================================================" 
echo "============== This command is for ubuntu22.04. ==============="
echo "===============================================================" 

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

submodule_url=$(echo ${CIRCLE_REPOSITORY_URL} | sed "s/${CIRCLE_PROJECT_REPONAME}/${module_name}/")

echo $submodule_url
if [[ -n ${ORGANIZATION_NAME} ]]; then
  master_org=$(echo $CIRCLE_REPOSITORY_URL | awk -F "/" '{ print $(NF-1) }' | awk -F ":" '{ print $NF }')
  submodule_url=$(echo ${submodule_url} | sed "s/${master_org}/${organization_name}/")
  echo $submodule_url
fi

function use-key() {
  # $1 : ${SUBM_FINGER_PRINT}
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

# reset config
rm -rf ~/.ssh/config

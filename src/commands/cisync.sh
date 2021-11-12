Cisync() {
    MERGE_FROM=$(eval echo "$CIRCLE_BRANCH")
    if [ "${MERGE_TO}" = "ALL" ]; then
        git branch -r | grep -v '\->' | while read -r remote; do
            git branch --track "${remote#origin/}" "$remote" || true
        done
        git fetch --all
        MERGE_TO=$(git for-each-ref --format="%(refname:short)" refs/heads/ | grep -v "${MERGE_FROM}")
    fi

    echo "===="
    echo "from: ${MERGE_FROM}"
    echo "  to: ${MERGE_TO}"
    echo "===="

    # FOR LOCAL
    # MERGE_FROM="alpha"
    # MERGE_TO=$(git for-each-ref --format="%(refname:short)" refs/heads/ | grep -v "${MERGE_FROM}")

    cp -Rp .circleci ../
    git config --global user.name "${USER_NAME}"
    git config --global user.email "${USER_EMAIL}"

    for _sync_branch in ${MERGE_TO}; do
        echo "${_sync_branch}"
        git checkout "${_sync_branch}"
        rm -rf .circleci
        cp -Rp ../.circleci ./
        git add .circleci
        git diff-index --quiet HEAD || git commit -m "[skip ci] cisync auto merge from ${MERGE_FROM} -> ${_sync_branch}"
        git push
    done

    echo "OK"
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    Cisync
fi

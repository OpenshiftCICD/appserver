#!/bin/bash
# author: Thomas Herzog
# date: 18/01/12

# Execute in script dir
cd $(dirname ${0})

# Source environment
source ./.openshift-env
source ./.openshift-secret-env

function create() {
  ./openshift-secrets.sh create

  # The app service
  oc new-app -f ../templates/service-app.yml \
    -p "NAME=${APP_SERVICE}" \
    -p "MAVEN_REPSOTIRY_URL=${MAVEN_REPSOTIRY_URL}" \
    -p "GIT_REPO_URL=${APP_SERVICE_GIT_URL}" \
    -p "GIT_REPO_REF=${APP_SERVICE_GIT_REF}" \
    -p "SECRET_GITHUB_SSH=${SECRET_GITHUB_SSH}" \
    -p "SECRET_GITHUB_HOOK=${SECRET_GITHUB_HOOK}" \
    -p "SECRET_NEXUS_SERVICE=${SECRET_NEXUS_SERVICE}"
}

function delete() {
  ./openshift-secrets.sh delete

  oc delete all -l app=${APP_SERVICE}
  oc delete secrets -l app=${APP_SERVICE}
  oc delete pvc -l app=${APP_SERVICE}
  oc delete bc -l app=${APP_SERVICE}
}

case "$1" in
  create|delete|createDev|deleteDev)
    ${1}
    ;;
  *)
    echo "./openshift-appserver.sh [create|delete|createDev|deleteDev]"
    ;;
esac

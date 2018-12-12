#!/bin/bash -eu

# PREREQS
# > cortex configure set-profile <your-prod-profile>
# > cortex docker login 

###
#
#  USAGE: sh ./migrate.sh <jobDefFile.json> <dockerhubOrg> <dockerImageNameAndTag> <cortexTenant> [<cortexDeployment>]
#    Ex. sh ./migrate.sh my-job.json c12e ansible:latest colttest cortex-dev
#
###

JOBDEF_FILE=$1
# Organization/User Namespace in DockerHub
DOCKERHUB_ORG=${2:-c12e}
# Image name published to DockerHub
# The image name and tag that exists in DockerHub
IMAGE=${3:-ansible}
#IMAGE=cat ${JOBDEF_FILE} | jq .image | sed 's/^.*registry.cortex.*:5000\/.*\///g'
# The Cortex account/tenant name
TENANT_NAME=${4:-company}
# The Cortex deployment that the tenant exists in, should be not needed for PROD
CORTEX_ENV=${5:-cortex}
SECURED_REGISTRY=private-registry.${CORTEX_ENV}.insights.ai


### Docker pull, tag, push ...
echo "*** Attempting to pull '${DOCKERHUB_ORG}/${IMAGE}' from hub.docker.com"
docker pull ${DOCKERHUB_ORG}/${IMAGE} || (echo "Unable to pull '${DOCKERHUB_ORG}/${IMAGE}'" && exit 1)

echo "*** Retagging '${DOCKERHUB_ORG}/${IMAGE}' as '${SECURED_REGISTRY}/${TENANT_NAME}/${IMAGE}'"
docker tag ${DOCKERHUB_ORG}/${IMAGE} ${SECURED_REGISTRY}/${TENANT_NAME}/${IMAGE}

echo "*** Pushing '${SECURED_REGISTRY}/${TENANT_NAME}/${IMAGE}'"
docker push ${SECURED_REGISTRY}/${TENANT_NAME}/${IMAGE} || (echo "Unable to push '${SECURED_REGISTRY}/${TENANT_NAME}/${IMAGE}', Are you sure you logged in?" && exit 1)

### Update job def...
echo "*** Updating job definition file: ${JOBDEF_FILE}:"
sed -i "_backup" "s/\(registry\.cortex.*:5000\/\).*\(\/.*\)/\1${TENANT_NAME}\2/g" ${JOBDEF_FILE} || (echo "Failed to update job definition file." && exit 1)
cat ${JOBDEF_FILE}
#read -n1 -r -p "Looks good? Press space to continue..." key

### Deploy ...
if [[ ${JOBDEF_FILE} == *.json ]]; then
    cortex jobs save ${JOBDEF_FILE}
else
    cortex jobs save ${JOBDEF_FILE} --yaml
fi

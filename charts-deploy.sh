#! /bin/bash

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Uploads charts from the charts folder to gitlab."
   echo
   echo "Syntax: scriptTemplate [-r|p|u]"
   echo "options:"
   echo "r     The git helm package registry location that contains the helm charts for the project"
   echo "p     The password for the helm registry"
   echo "u     The username for the helm registry"
   echo
}

# Get the options
while getopts ":h:r:p:u:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      \?) # Invalid option
         echo "Error: Invalid option"
	 Help
         exit;;
      r) # The git helm package registry location that contains the helm charts for the projects
	 REGISTRY=${OPTARG};;
      p) # The password for the helm chart
	 TOKEN=${OPTARG};;
      u) # The username for the helm chart
    USERNAME="${OPTARG}";;
   esac
done

CHARTS_PATH="./charts"
cd ${CHARTS_PATH}

helm registry login ${REGISTRY} --username ${USERNAME} --password ${PASSWORD}

declare -a dirs
i=1
for d in */
do
    dirs[i++]="${d%/}"
done
echo "There are ${#dirs[@]} charts in the current path"
for((i=1;i<=${#dirs[@]};i++))
do
  directory="${dirs[i]}"

  chart_name="${directory}"

  # read the name attribute from the chart.yaml file
  chart_name=$(yq '.name' "${directory}/Chart.yaml")

  # read the version attribute from the chart.yaml file
  chart_version=$(yq '.version' "${directory}/Chart.yaml")

  REPO_EXISTS=$(aws ecr describe-repositories | jq -r --arg repoName "${chart_name}" '.repositories[] | select( .repositoryName == $repoName )' | jq length)

  if [ -z "${REPO_EXISTS}" ]
  then
    aws ecr create-repository --repository-name "${chart_name}" --region "us-east-1" 1> /dev/null    
  fi

  echo "Creating helm chart: ${chart_name} with version: ${chart_version} and pushing to registry: ${REGISTRY}"

  helm package ${directory}
  helm push ${chart_name}-${chart_version}.tgz "oci://${REGISTRY}/"

done

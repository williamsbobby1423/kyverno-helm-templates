#! /bin/bash

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Uploads charts from the charts folder to gitlab."
   echo
   echo "Syntax: scriptTemplate [-r|t|p|u]"
   echo "options:"
   echo "r     The git helm package registry location that contains the helm charts for the project"
   echo "t     The the personal access token or the deploy token which allows registration of the helm charts"
   echo "p     The project id for the helm repository"
   echo "u     The username for the token"
   echo
}

# Get the options
while getopts ":h:r:t:p:u:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      \?) # Invalid option
         echo "Error: Invalid option"
	 Help
         exit;;
      r) # The git helm package registry location that contains the helm charts for the projects
	 REPO=${OPTARG};;
      t) # The the personal access token or the deploy token which allows registration of the helm charts
	 TOKEN=${OPTARG};;
      p) # The project id for the helm repository
	 PROJECT_ID="${OPTARG}";;
      u) # The username for the token
    USERNAME="${OPTARG}";;
   esac
done

CHARTS_PATH="./charts"
cd ${CHARTS_PATH}

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

  echo ${REPO}
  echo ${chart_name}
  echo ${USERNAME}
  echo ${TOKEN}

  helm repo add ${chart_name} --username ${USERNAME} --password ${TOKEN} ${REPO}

  helm package ${chart_name}
  helm cm-push ${chart_name}*.tgz ${chart_name}
done

#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
export fly_target=${fly_target:-tutorial}
export pipelinename=${pipelinename:-07_myresource_jobs}
echo "Concourse API target ${fly_target}"
echo "Concourse API $ATC_URL"
echo "Tutorial $(basename $DIR)"

pipeline=$1; shift
if [[ "${pipeline}" != "simple" && "${pipeline}" != "renamed" ]]; then
  echo "USAGE: run.sh [simple|renamed]"
  exit 1
fi

pushd $DIR
  yes y | fly -t ${fly_target} set-pipeline --config pipeline.yml --pipeline ${pipeline}
  fly unpause-pipeline --pipeline ${pipeline}
  curl $ATC_URL/pipelines/${pipeline}/jobs/job-hello-world/builds -X POST
  fly -t ${fly_target} watch -j ${pipeline}/job-hello-world
popd

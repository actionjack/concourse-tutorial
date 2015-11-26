#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export pipeline=${pipeline:-12_run_tests_before_deploy}
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Concourse API $ATC_URL"
echo "Tutorial $(basename $DIR)"

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

stub=$1; shift
if [[ "${stub}X" == "X" ]]; then
  echo "USAGE: run.sh path/to/credentials.yml"
  exit 1
fi
stub=$(realpath $stub)
if [[ ! -f ${stub} ]]; then
  echo "USAGE: run.sh path/to/credentials.yml"
  exit 1
fi

pushd $DIR
  yes y | fly -t ${fly_target} set-pipeline --config pipeline.yml --pipeline ${pipeline} --load-vars-from ${stub}
  fly unpause-pipeline --pipeline ${pipeline}
  curl $ATC_URL/pipelines/main/jobs/job-test-deploy-app/builds -X POST
  fly -t ${fly_target} watch -j ${pipeline}/job-test-deploy-app
popd

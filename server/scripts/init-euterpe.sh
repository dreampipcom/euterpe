#!/bin/bash
# init weagle
echo -e "\033[0;62m\033[0;49;35m"
set -a && source ../.env.common.private && set +a
set -a && source ../.env.ingress.private && set +a
root_dir="$(pwd)"

log () {
  echo -e "\033[0;49;35m"
  # warning
  if [[ "$2" == "2" ]]; then
    echo -e "\033[35;43m$1\033[0m"
  fi
  # error
  if [[ "$2" == "1" ]]; then
    echo -e "\033[35;41m\033[33m$1\033[0m"
  fi
  # success
  if [[ "$2" == "0" ]]; then
    echo -e "\033[35;42m$1\033[0m"
  fi
  # normal
  if [[ "$2" == "" ]]; then
    echo -e "\033[35;46m$1\033[0m"
  fi
}

prompt () {
  log "$1" 2
  read answer
  echo "$answer"
}

gosu () {
  if [ $( id -u ) -ne 0 ]; then
    log "dp::(auth)::this command needs sudo, please add password for %p: " 2
      sudo -v
      # exit $?
  fi
}

take () {
  log "dp::(idle)::let's wait $1 seconds for $2." 2
  while true; do echo -n .; sleep 1; done | pv -s $1  -S -F '%t %p' > /dev/null
}


log "dp::janus::${EUTERPE_ENV}::ingress::(busy)::preparing Janus (Ingress: Traefik, Grafana, Prometheus) configuration files." 2

cd ../radio
mkdir data
cd data
mkdir charts
mkdir manifests
cd $root_dir

cd ../radio

origin="./_icecast.yaml"
destination="./data/charts/icecast.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_icecast-service.yaml"
destination="./data/charts/icecast-service.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination

origin="./_icecast-config.yaml"
destination="./data/charts/icecast-config.yaml"
tmpfile=$(mktemp --tmpdir=.)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination


log "dp::janus::${EUTERPE_ENV}::ingress::(idle)::all good." 0

#!/bin/bash
# init.sh
echo -e "\033[0;62m\033[0;49;35m"
set -a && source .env && set +a

root_dir="$(pwd)"

# prepare config
echo "dp::euterpe::(busy)::preparing Euterpe Icecast configuration files."

cd icecast
rm _*.conf
for file in *.conf
do
	origin=$file
	destination="_$file"
	tmpfile=$(mktemp)
  cp -p $origin $tmpfile
	cat $origin | envsubst > $tmpfile && mv $tmpfile $destination
done
cd $root_dir

cd ez
rm _*.conf
for file in *.conf
do
	origin="$file"
	destination="_$file"
	tmpfile=$(mktemp)
  cp -p $origin $tmpfile
	cat $origin | envsubst > $tmpfile && mv $tmpfile $destination
done
cd $root_dir

# legacy sed, use if daemons are enabled already
# sed -i ./icecast/default.conf s/EUTERPE_USER/$EUTERPE_USER/g
# sed -i ./icecast/default.conf s/EUTERPE_PASSWORD/$EUTERPE_PASSWORD/g
# sed -i ./icecast/default.conf s/EUTERPE_BASEDIR/$EUTERPE_BASEDIR/g
# sed -i ./icecast/default.conf s/EUTERPE_HOSTNAME/$EUTERPE_HOSTNAME/g
# sed -i ./icecast/default.conf s/EUTERPE_ADMIN/$EUTERPE_ADMIN/g
# sed -i ./icecast/default.conf s/EUTERPE_IP/$EUTERPE_IP/g
# sed -i ./icecast/default.conf s/EUTERPE_MNT_MAIN/$EUTERPE_MNT_MAIN/g
# sed -i ./icecast/default.conf s/EUTERPE_MNT_LIVE/$EUTERPE_MNT_LIVE/g
# sed -i ./icecast/default.conf s/EUTERPE_MNT_ROTATIONS/$EUTERPE_MNT_ROTATIONS/g
# sed -i ./icecast/default.conf s/EUTERPE_MNT_BASE/$EUTERPE_MNT_BASE/g
# sed -i ./icecast/default.conf s/EUTERPE_UNIX_UID/$EUTERPE_UNIX_UID/g
# sed -i ./icecast/default.conf s/EUTERPE_UNIX_GID/$EUTERPE_UNIX_GID/g
# sed -i ./icecast/default.conf s/EUTERPE_CLIENTS_NUM/$EUTERPE_CLIENTS_NUM/g
# sed -i ./icecast/default.conf s/EUTERPE_SOURCES_NUM/$EUTERPE_SOURCES_NUM/g
# sed -i ./icecast/default.conf s/EUTERPE_THREADS_NUM/$EUTERPE_THREADS_NUM/g
# sed -i ./icecast/default.conf s/EUTERPE_QUEUESIZE_NUM/$EUTERPE_QUEUESIZE_NUM/g
# sed -i ./icecast/default.conf s/EUTERPE_CLIENT_TIMEOUT_NUM/$EUTERPE_CLIENT_TIMEOUT_NUM/g
# sed -i ./icecast/default.conf s/EUTERPE_HEADER_TIMEOUT_NUM/$EUTERPE_HEADER_TIMEOUT_NUM/g
# sed -i ./icecast/default.conf s/EUTERPE_SOURCE_TIMEOUT_NUM/$EUTERPE_SOURCE_TIMEOUT_NUM/g
# sed -i ./icecast/default.conf s/EUTERPE_BITRATE/$EUTERPE_BITRATE/g
# sed -i ./icecast/default.conf s/EUTERPE_SAMPLERATE/$EUTERPE_SAMPLERATE/g
# sed -i ./icecast/default.conf s/EUTERPE_SERVER_CHANNELS_NUM/$EUTERPE_SERVER_CHANNELS_NUM/g

echo -e "\033[0;62m\033[0;49;32m"
echo "dp::euterpe::(idle)::all good."

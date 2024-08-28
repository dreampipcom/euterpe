#!/bin/bash
# init.sh
echo -e "\033[0;62m\033[0;49;35m"
cp ../.env ./env
set -a && source .env && set +a

root_dir="$(pwd)"

# install deps
echo "dp::euterpe::server::firewall::(busy)::preparing DreamWAF."
if [ "$(which fail2ban)" == "" ]; then
	echo "dp::euterpe::server::firewall::(busy)::installing fail2ban."
	apt update
	apt install fail2ban
else
	echo "dp::euterpe::server::firewall::(skip)::skipping fail2ban installation."
fi

echo "dp::euterpe::server::icecast::(busy)::preparing DreamAudioCastServer."
if [ "$(which icecast2)" == "" ]; then
	echo "dp::euterpe::server::firewall::(busy)::installing Icecast."
	apt update
	apt install icecast2
else
	echo "dp::euterpe::server::icecast::(skip)::skipping Icecast installation."
fi

echo "dp::euterpe::server::ez::(busy)::preparing DreamRandomCast."
if [ "$(which ezstream)" == "" ]; then
	echo "dp::euterpe::server::firewall::(busy)::installing EZ Stream."
	apt update
	apt install ezstream
else
	echo "dp::euterpe::server::icecast::(skip)::skipping EZ Stream installation."
fi

echo "dp::euterpe::server::archive::(busy)::preparing DreamBucketFuse."
if [ "$(which /usr/bin/rclone)" == "" ]; then
	echo "dp::euterpe::server::archive::(busy)::installing GCP Fuse."
	export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
	echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.asc
	apt update
	apt install gcsfuse
else
	echo "dp::euterpe::server::icecast::(skip)::skipping GCP Fuse installation."
fi

# prepare daemons
echo "dp::euterpe::server::archive::(busy)::preparing GCP Fuse."
cd daemon
rm _*.service
origin="dp-audio-archive.service.template"
destination="_dp-audio-archive.service"
tmpfile=$(mktemp)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination
cd $root_dir
# to-do: add GCP auth config setup.
# [DPTM-10]: https://www.notion.so/angeloreale/Euterpe-Finish-Server-GCP-init-script-465c147d63d54511867e553b8aeb1057?pvs=4

# prepare configs
echo "dp::euterpe::server::icecast::(busy)::preparing Euterpe Icecast configuration files."
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

echo "dp::euterpe::server::ez::(busy)::preparing Euterpe EZ configuration files."
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

echo "dp::euterpe::server::firewall::(busy)::preparing DreamWAF configuration files."
cd firewall
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

# copy files
mnt_dir="/mnt/audio-archive"
if [ -d "$mnt_dir" ]; then
	echo "dp::euterpe::server::ez::(busy)::copying configs to mnt."
	cp ez/_*.conf $mnt_dir
else
	echo "dp::euterpe::server::ez::(error)::audio-archive is not mounted."
	exit 1;
fi

firewall_dir="/etc/fail2ban"
if [ -d "$firewall_dir" ]; then
	echo "dp::euterpe::server::firewall::(busy)::copying configs to fail2ban."
	cd firewall
	cp _dp-patience.local "$firewall_dir/jail.d/dp-patience.local"
	cp _dp-patience.conf "$firewall_dir/filter.d/dp-patience.conf"
else
	echo "dp::euterpe::server::firewall::(error)::fail2ban seems to still be missing ::mystery-tune-plays::."
	exit 1;
fi
cd $root_dir

daemon_dir="/etc/systemd/system"
if [ -d "$daemon_dir" ]; then
	echo "dp::euterpe::server::systemd::(busy)::copying daemons to systemd."
	cd daemon
	for file in *.service
	do
		cp $file $daemon_dir
		systemctl enable $file
		systemctl daemon-reload
		systemctl start $file
	done
else
	echo "dp::euterpe::server::systemd::(error)::this os systemd dir might be different."
	exit 1;
fi
cd $root_dir

# make a playlist
echo "dp::euterpe::server::vibes::(busy)::making a playlist."
cp static/* $mnt_dir
cd $mnt_dir
find -type f -iname "jingle.mp3" > playlist-base.m3u
find -type f -iname "*.mp3" -or -iname "*.flac" -or -iname "*.m4a" > playlist.m3u
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
echo "dp::euterpe::server::(idle)::all good."

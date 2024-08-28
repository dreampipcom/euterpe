#!/bin/bash
# init.sh
echo -e "\033[0;62m\033[0;49;35m"
cp ../../.env ./.env
set -a && source .env && set +a

root_dir="$(pwd)"

# update rpi
sudo apt-get update
sudo apt-get upgrade

# install darkice
echo "dp::euterpe::client::raspberry::darkice::(busy)::Installing Darkice."
Wget https://github.com/x20mar/darkice-with-mp3-for-raspberry-pi/blob/master/darkice_1.0.1-999~mp3+1_armhf.deb?raw=true
mv darkice_1.0.1-999~mp3+1_armhf.deb?raw=true darkice_1.0.1-999~mp3+1_armhf.deb
sudo apt-get install libmp3lame0 libtwolame0
sudo dpkg -i darkice_1.0.1-999~mp3+1_armhf.deb

# install icecast
sudo apt-get install icecast2

# prepare configs
echo "dp::euterpe::client::raspberry::darkice::(busy)::preparing Darkice configuration files."
cd darkice
rm _*.conf
origin="dp-rpi.cfg"
destination="_$file"
tmpfile=$(mktemp)
cp -p $origin $tmpfile
cat $origin | envsubst > $tmpfile && mv $tmpfile $destination
cd $root_dir

daemon_dir="/etc/systemd/system"
if [ -d "$daemon_dir" ]; then
	echo "dp::euterpe::client::systemd::(busy)::copying daemons to systemd."
	cd daemon
	for file in *.service
	do
		cp $file $daemon_dir
		systemctl enable $file
		systemctl daemon-reload
		systemctl start $file
	done
else
	echo "dp::euterpe::client::systemd::(error)::this os systemd dir might be different."
	exit 1;
fi
cd $root_dir

# start broadcast
echo "dp::euterpe::client::raspberry::vibes::(busy)::enabling and starting Icecast Service."
sudo service icecast2 enable
sudo service icecast2 start

echo -e "\033[0;62m\033[0;49;32m"
echo "dp::euterpe::client::raspberry::(idle)::all good."

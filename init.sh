# !/bin/sh
# init.sh

sed -i ./icecast/default.conf s/EUTERPE_PASSWORD/$EUTERPE_PASSWORD/g
sed -i ./icecast/default.conf s/EUTERPE_BASEDIR/$EUTERPE_BASEDIR/g
sed -i ./icecast/default.conf s/EUTERPE_HOSTNAME/$EUTERPE_HOSTNAME/g
sed -i ./icecast/default.conf s/EUTERPE_ADMIN/$EUTERPE_ADMIN/g
sed -i ./icecast/default.conf s/EUTERPE_IP/$EUTERPE_IP/g
sed -i ./icecast/default.conf s/EUTERPE_MNT_MAIN/$EUTERPE_MNT_MAIN/g
sed -i ./icecast/default.conf s/EUTERPE_MNT_LIVE/$EUTERPE_MNT_LIVE/g
sed -i ./icecast/default.conf s/EUTERPE_MNT_ROTATIONS/$EUTERPE_MNT_ROTATIONS/g
sed -i ./icecast/default.conf s/EUTERPE_MNT_BASE/$EUTERPE_MNT_BASE/g
sed -i ./icecast/default.conf s/EUTERPE_UNIX_UID/$EUTERPE_UNIX_UID/g
sed -i ./icecast/default.conf s/EUTERPE_UNIX_GID/$EUTERPE_UNIX_GID/g
sed -i ./icecast/default.conf s/EUTERPE_CLIENTS_NUM/$EUTERPE_CLIENTS_NUM/g

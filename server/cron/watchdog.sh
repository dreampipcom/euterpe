#!/bin/bash
##############################################################################
## Based off: Darkice Watchdog
##
## This script checks a darkice live stream on a local or remote icecast 
## server and restart darkice if the stream is down.
##
## Niels Dettenbach <nd@syndicat.com>
## (c) 2009 GPL
## v0.3
##
## Modified by: Angelo Reale <angeloreale@mailmasker.com>
## HPL3-ECO-AND-ANC 2024—Present
## Purizu di Angelo Reale Caldeira de Lemos
## IT02925300903
## 
##
##
##
## installation:
## -------------
##
## - adjust settings
##
## - make it executable with:
##   chmod +x dp.watchdog
##
## - add it to /etc/crontab - i.e.:
## 
##  */1 * * * *     root	/full/path/to/icecast.watchdog > /dev/null
##
###############################################################################


### settings

# icecast status URL
URL='127.0.0.7:EUTERPE_PORT/status-json.xsl?mount=/EUTERPE_MNT_MAIN'

# filename of stream
TEXTTOSEARCH='EUTERPE_MNT_MAIN'

# timeout
TIMEOUT=10

# sleep within restart
SLEEP=5

# log file
LOGFILE=/var/log/dp_euterpe_watchdog

# curl binary
CURL=`which curl`

## endof settings

DATE=$(date)

CUR=$($CURL --connect-timeout ${TIMEOUT} --max-time ${TIMEOUT} -3 --silent ${URL}) 
TEST="$(echo $CUR | grep ${TEXTTOSEARCH})"
# If not zero, server is OK 
if [[ ! $TEST == "" ]]; then 
	echo $DATE "dp::euterpe::all::(normal)::stream is OK" >> $LOGFILE; 
else
	echo $DATE "dp::euterpe::all::(degraded)::stream down" >> $LOGFILE;
	#restart dp:euterpe
	service dp-ez-rotation stop
	service dp-ez-base stop
	service dp-icy stop
	service dp-audio-archive stop
	sleep $SLEEP
	service dp-audio-archive start
	service dp-icy start
	service dp-ez-base start
	service dp-ez-rotation start
fi
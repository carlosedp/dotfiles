#!/bin/bash
#
# Script to perform backups based on rsync using a mechanism similar to Apple´ Time Machine.
# Each run creates a new backup set with incremental changes and hard-links to unchanged files.
#
# Usage: ./backup.sh -o [origin_dir] -d [destination_dir] [params]
#
# Params:
#       --origin | -o         |  Origin dir
#       --dest | -d           |  Destination dir
#       --dry                 |  Dry run, do not perform sync
#       --excludes-file=file  |  Excludes files/dirs listed on file (one match per line)
#


export PATH=${PATH}:.

date=`date "+%Y%m%d%H%M%S"`

# Default origin and destination path
ORIGINPATH=``
DEST=''

RSYNC_PARAM="-avzPx"        # Set permissions ( -a = -rlptgoD)
RSYNC_PARAM="-rltgoDvzPx"   # Don't set permissions
RSYNC_DEL="--delete --delete-excluded"
CHECK_PARAM="--modify-window=2"
#CHECK_PARAM="--size-only"
RSYNCDRY=0
RSYNC_EXCLUDE=""

#Parse command line arguments
for i in $*
do
	case $i in
    --origin=*)
        ORIGINPATH=`echo $i | sed 's/[-a-zA-Z0-9]*=//' | sed 's/\/$//'`
        continue
        ;;
    -o)
        ORIGINPATH=`echo $2 | sed 's/\/$//'`
        shift 2
        continue
        ;;
    --dest=*)
        DEST=`echo $i | sed 's/[-a-zA-Z0-9]*=//' | sed 's/\/$//'`
        ;;
    -d)
        DEST=`echo $2 | sed 's/\/$//'`
        shift 2
        continue
        ;;
    --dry)
        RSYNC_PARAM="${RSYNC_PARAM}n"
        RSYNCDRY=1
        continue
        ;;
    --excludes-file=*)
        EXCLUDE_FILE=`echo $i | sed 's/[-a-zA-Z0-9]*=//' | sed 's/\/$//'`
        RSYNC_EXCLUDE="--exclude-from=${EXCLUDE_FILE}"
        ;;
    -*)
        echo "Unknown parameter '$i'"
        exit 1
		;;
 	esac
done

# Check if origin dir is passed
if [ -z ${ORIGINPATH} ]; then
    echo "You must supply an origin backup directory"
    exit 1
fi

# Check if origin dir exists
if [ ! -d ${ORIGINPATH} ]; then
    echo "Error: '${ORIGINPATH}' origin does not exist!!"
    echo "EXITING"
    exit 1
fi

# Check if destination dir is passed
if [ -z ${DEST} ]; then
    echo "You must supply a destination backup directory"
    exit 1
fi

# Check if destination dir exists
if [ ! -d ${DEST} ]; then
    echo "Error: '${DEST}' destination does not exist!!"
    echo "EXITING"
    exit 1
fi

# Convert relative paths to absolute
PATHTMP=`cd ${ORIGINPATH}; pwd`
ORIGINPATH=${PATHTMP}
PATHTMP=`cd ${DEST}; pwd`
DEST=${PATHTMP}

# Check if destination symbolic links exists
if [ ! -L ${DEST}/latest ]; then
    echo "Creating initial dir"
    ln -s ${DEST}/. ${DEST}/latest
fi

echo "Origin dir: ${ORIGINPATH}"
echo "Dest. dir:  ${DEST}"

rsync ${RSYNC_PARAM} ${CHECK_PARAM} ${RSYNC_DEL} ${RSYNC_EXCLUDE} --link-dest="${DEST}/latest" "${ORIGINPATH}/" "${DEST}/incomplete_backup-${date}/"

if [ $? -eq 0 ] && [ ${RSYNCDRY} -ne 1 ]; then
    mv ${DEST}/incomplete_backup-${date} ${DEST}/backup-${date}
    touch ${DEST}/backup-${date}
    rm -f ${DEST}/latest
    ln -s ${DEST}/backup-${date} ${DEST}/latest
    echo "Backup complete."
    exit 0
else
    rm -rf ${DEST}/incomplete_backup-${date}
    if [  ${RSYNCDRY} -ne 1 ]; then
        echo "Backup Error."
        exit 1
    else
        echo "Backup Complete (Dry Run)."
        exit 0
    fi
fi


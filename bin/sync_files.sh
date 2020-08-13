#!/bin/bash
#
usage() {
    echo "Usage: ./sync_files.sh -o [origin_dir] -d [destination_dir] [params]"
    echo ""
    echo "Params:"
    echo "      --origin | -o         |  Origin dir"
    echo "      --dest | -d           |  Destination dir"
    echo "      --dry                 |  Dry run, do not perform sync"
    echo "      --del                 |  Delete destination if not present on origin"
    echo "      --backup              |  Backup deleted/overwritten files into [dest]/Backup"
    echo "      --excludes-file=file  |  Excludes files/dirs listed on file (one match per line)"
    exit 1
}

# RSYNC_PARAM="-avuP"
RSYNC_PARAM="-rlptgoDvuP"
RSYNC_DEL="--delete --delete-excluded"
CHECK_PARAM="--modify-window=2"     #Windows Friendly way to check file modification

RSYNC_EXCLUDE=""
#EXCLUDE_FILE="${MY_DIR}/cygwin_excludes"
#RSYNC_EXCLUDE="--exclude-from=${EXCLUDE_FILE}"
#RSYNC_EXCLUDE="--exclude */psptoolchain/*"

# Check if parameters are passed
if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

#Parse command line arguments
for i in $*
do
	case $i in
    -h | --help)
        usage
        exit 0
        ;;
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
        continue
        ;;
    --del)
        RSYNC_PARAM="${RSYNC_PARAM} ${RSYNC_DEL}"
        continue
        ;;
    --backup)
        RSYNC_PARAM="${RSYNC_PARAM} --backup --backup-dir=${DEST}/Backup"
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

# Check if the origin and destination paths are passed
if [ -z ${ORIGINPATH+x} ] || [ -z ${DEST+x} ]; then
    echo "Error: Wrong parameters!!"
    usage
    exit 1
fi

# Check if origin dir exists
if [ ! -d ${ORIGINPATH} ]; then
echo "Error: '${ORIGINPATH}' origin does not exist!!"
echo "EXITING"
exit 1
fi

# Check if destination dir exists
if [ ! -d ${DEST} ]; then
    echo "Error: '${DEST}' destination does not exist!!"
    echo "EXITING"
    exit 1
fi

# Set origin as current dir
if [ ${ORIGINPATH} == "." ]; then
    ORIGINPATH=`pwd`
fi

# Print output dirs
echo "Origin Path:" ${ORIGINPATH}
echo "Destination Path:" ${DEST}


EXEC_COMMAND="rsync ${RSYNC_PARAM} ${CHECK_PARAM} ${RSYNC_EXCLUDE} ${ORIGINPATH}/ ${DEST}"
echo ${EXEC_COMMAND}
${EXEC_COMMAND}

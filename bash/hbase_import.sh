#!/bin/bash

# Import data from files to HBase.
# Usage:
#   ./import_hbase.sh [import-direct|import-bulk] tablename /path/from/data [/path/to/hfile]

ROOT=`pwd`
HBASE="$ROOT/bin/hbase"
if [ ! -f "$HBASE" ]
then
	echo "$ROOT is not hbase home directory; please change directory to HBASE_HOME"
	exit 1
fi

CMD_IMPORT="org.apache.hadoop.hbase.mapreduce.ImportTsv"
CMD_BULK_LOAD="org.apache.hadoop.hbase.mapreduce.LoadIncrementalHFiles"
IMPORT_COLS="HBASE_ROW_KEY,cf:col1,cf:col2,cf:col3"
IMPORT_TBL=$2
IMPORT_INPUT=$3
IMPORT_BULK_OUTPUT=$4
LOG_PATH="$ROOT/import.log"


case $1 in
    import-direct)
        echo "starting import data directly, redirect the output to $LOG_PATH"
        $HBASE $CMD_IMPORT -Dimporttsv.columns=$IMPORT_COLS $IMPORT_TBL $IMPORT_INPUT
        ;;
    import-bulk)
        echo "starting import data with bulk, redirect the output to $LOG_PATH"
        $HBASE $CMD_IMPORT -Dimporttsv.columns=$IMPORT_COLS \
                           -Dimporttsv.bulk.output=$IMPORT_BULK_OUTPUT \
                            $IMPORT_TBL $IMPORT_INPUT 
        $HBASE $CMD_BULK_LOAD $IMPORT_BULK_OUTPUT $IMPORT_TBL 
        ;;
    *)
        echo "Usage: $0 [import-direct|import-bulk] tablename /path/to/data [/path/to/hfile]"
        ;;
esac

if [ $? -ne 0 ]
then
    echo "import failure, refer to the log file $LOG_PATH"
    exit 1
fi

#!/bin/bash
#
# This script takes as input a single file that contains a list of RDF files.
# For each RDF file in the list, this script checks that the load state == 2 (success)

LOAD_STATUS=2
while read f; do
   path=$(dirname $f)
   file=$(basename $f)
   echo "Checking load status for: path=$path file=$file"

   echo "0000000000 select ll_state from DB.DBA.load_list where ll_file='$path/$file';"

   echo "11111111111"

   /usr/local/virtuoso-opensource/bin/isql-v 1111 dba dba exec="select ll_state from DB.DBA.load_list where ll_file='$path/$file';"

echo "222222222222"
   status=$(/usr/local/virtuoso-opensource/bin/isql-v 1111 dba dba exec="select ll_state from DB.DBA.load_list where ll_file='$path/$file';" | head -n 9 | tail -n 1)
   echo "STATUS: $status"
   if [[ $status != 2 ]]
	    then
	    LOAD_STATUS=$status
		echo "LOAD ERROR DETECTED FOR: path=$path file=$file"
	    fi
done < $1

if [[ $LOAD_STATUS != 2 ]]
then
        echo "Detected error. check-load-states.sh returning with exit code = 1"
	    exit 1
fi




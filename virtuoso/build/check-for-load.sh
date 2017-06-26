#!/bin/bash
#
# This script monitors the /load_request_virtuoso directory. If a new file is
# detected then a Virtuoso bulk load is initiated.  The files in
# this directory must contain a list of files to load.
#

inotifywait -m $1 -e create,moved_to,attrib |
    while read path action file; do
        echo "The file '$file' appeared in directory '$path' via '$action'"
        if [[ "$file" == *.load ]]
	then
	    SUCCESS_FILE="$path$file.success"
            FAIL_FILE="$path$file.error"

	    # remove any previous .success or .error files (in case
	    # this is a retry of a previous load attempt)
	    # TODO: along with removing any previous success/fail files, this script needs to clear the
	    # file being loaded from the Virtuoso  DB.DBA.LOAD_LIST table, or maybe just set its status to 0
	    # delete FROM DB.DBA.LOAD_LIST
	    if [[ -f $SUCCESS_FILE ]]
	    then
		rm -f $SUCCESS_FILE
	    fi
	    if [[ -f $FAIL_FILE ]]
	    then
		rm -f $FAIL_FILE
	    fi

	    # register each file to be loaded with the Virtuoso loader using the isql ld_dir command
	    echo "ABOUT TO REGISTER..."
        /usr/bin/register-files-with-virtuoso-loader.sh $path$file

	    # create an isql rdf_loader_run script that calls the loader cores/2.5 times
	    /usr/bin/run-virtuoso-loader.sh | tee $path$file.log

	    # exit=0 == successful load, failure otherwise
        /usr/bin/check-load-states.sh $path$file

	    if [[ $? == 0 ]]
	    then
		touch $SUCCESS_FILE
	    else
		touch $FAIL_FILE
	    fi
	fi
    done

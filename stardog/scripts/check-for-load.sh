#!/bin/bash
#
# This script monitors the /load_request directory. If a new file is
# detected then a StarDog bulk load is initiated.  The files in
# this directory must contain a list of files to load. The file name
# is composed of a user-specified name along with parameters to feed
# to the agload process and terminating with the '.load'
# suffix. Parameters are added as file suffixes using the format
# below:
#
#               .port_[port] :: REQUIRED - the port used by AllegroGraph
#          .repo_[repo-name] :: REQUIRED - the name of the repository in which to load
#      .format_[file-format] :: OPTIONAL - the format of the files that will be loaded;
#                                          DEFAULT = agload will attempt to determine the format
#    .catalog_[catalog-name] :: OPTIONAL - the name of the AllegroGraph catalog to use;
#                                          DEFAULT=root catalog
#                 .supersede :: OPTIONAL - if present, the repository will be deleted and re-created prior to loading
#
# Example: obo-ontologies.port_10035.repo_kabob.format_owl.catalog_mycatalog.supersede.load
#
# Note, parameters can be listed in any order as long as the filename is terminated with .load
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
            if [[ -f $SUCCESS_FILE ]]
            then
                rm -f $SUCCESS_FILE
            fi
            if [[ -f $FAIL_FILE ]]
            then
                rm -f $FAIL_FILE
            fi

	        unset SUPERSEDE_FLAG
	    
            # extract the load parameters from the file name
            arr=($(echo $file | tr "." "\n"))
            for param in "${arr[@]}"; do
                case $param in
                    port_*)
                    PORT=${param#"port_"}
                    ;;
                    format_*)
                    FORMAT=${param#"format_"}
                    ;;
                    repo_*)
                    REPO_NAME=${param#"repo_"}
                    ;;
                    supersede)
                    SUPERSEDE_FLAG="true"
                    ;;
                    catalog_*)
                    CATALOG=${param#"catalog_"}
                    ;;
                esac
	        done

            # check to make sure all required parameters have a value
            if [[ -z "$PORT" || -z "$REPO_NAME" ]]; then
                echo "Load file missing either the AllegroGraph port or repository name (or both).
                              Please make sure the .port_[PORT] and .repo_[REPONAME] suffixes are part of
                              the load file name to indicate the Allegrograph port and repository name, respectively."
                exit 1
            fi

            PARAMS=""
            if [[ ! -z "$FORMAT" ]]
            then
                PARAMS="$PARAMS --input $FORMAT"
            fi
            if [[ ! -z "$CATALOG" ]]
            then
                PARAMS="$PARAMS --catalog $CATALOG"
            fi
            if [[ ! -z "$SUPERSEDE_FLAG" ]]
            then
                PARAMS="$PARAMS --remove-all"
            fi

            load_command="/stardog-${STARDOG_VERSION}/bin/stardog data add ${REPO_NAME} --server-side --named-graph file://${file} -f ${FORMAT} $(cat ${path}${file} | tr \\n ' ')"

	        echo "EXECUTING LOAD COMMAND: $load_command"
	    
	        su -c "$load_command" | tee ${path}${file}.log
	    
            if [[ ${PIPESTATUS[0]} == 0 ]]
            then
                touch ${SUCCESS_FILE}
            else
                touch ${FAIL_FILE}
            fi
	    fi

        if [[ "$file" == *.create ]]
        then
            echo "Processing request to create new database: ${file}"
            SUCCESS_FILE="$path$file.success"
            FAIL_FILE="$path$file.error"

            # remove any previous .success or .error files (in case
            # this is a retry of a previous load attempt)
            if [[ -f ${SUCCESS_FILE} ]]
            then
                rm -f ${SUCCESS_FILE}
            fi
            if [[ -f ${FAIL_FILE} ]]
            then
                rm -f ${FAIL_FILE}
            fi

            # extract the load parameters from the file name
            arr=($(echo $file | tr "." "\n"))
            for param in "${arr[@]}"; do
                case ${param} in
                    repo_*)
                    REPO_NAME=${param#"repo_"}
                    ;;
                esac
            done

            # check to make sure all required parameters have a value
            if [[ -z "$REPO_NAME" ]]; then
                echo "Create database requires a repository name.
                              Please make sure the .repo_[REPONAME] suffix is part of
                              the load file name to indicate the Stardog repository name."
                exit 1
            fi

            create_command="/stardog-${STARDOG_VERSION}/bin/stardog-admin db create --name ${REPO_NAME}"

            echo "EXECUTING DATABASE CREATION COMMAND: ${create_command}"

            su -c "${create_command}" | tee ${path}${file}.log

            if [[ ${PIPESTATUS[0]} == 0 ]]
            then
                touch ${SUCCESS_FILE}
            else
                touch ${FAIL_FILE}
            fi
        fi

        if [[ "$file" == *.optimize ]]
        then
            echo "Processing request to optimize database: ${file}"
            SUCCESS_FILE="$path$file.success"
            FAIL_FILE="$path$file.error"

            # remove any previous .success or .error files (in case
            # this is a retry of a previous load attempt)
            if [[ -f ${SUCCESS_FILE} ]]
            then
                rm -f ${SUCCESS_FILE}
            fi
            if [[ -f ${FAIL_FILE} ]]
            then
                rm -f ${FAIL_FILE}
            fi

            # extract the load parameters from the file name
            arr=($(echo $file | tr "." "\n"))
            for param in "${arr[@]}"; do
                case ${param} in
                    repo_*)
                    REPO_NAME=${param#"repo_"}
                    ;;
                esac
            done

            # check to make sure all required parameters have a value
            if [[ -z "$REPO_NAME" ]]; then
                echo "Optimize database requires a repository name.
                              Please make sure the .repo_[REPONAME] suffix is part of
                              the load file name to indicate the Stardog repository name."
                exit 1
            fi

            optimize_command="/stardog-${STARDOG_VERSION}/bin/stardog-admin db optimize ${REPO_NAME}"

            echo "EXECUTING DATABASE OPTIMIZE COMMAND: ${optimize_command}"

            su -c "${optimize_command}" | tee ${path}${file}.log

            if [[ ${PIPESTATUS[0]} == 0 ]]
            then
                touch ${SUCCESS_FILE}
            else
                touch ${FAIL_FILE}
            fi
        fi

    done

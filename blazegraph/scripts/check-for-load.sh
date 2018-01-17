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
#
# Example: obo-ontologies.port_10035.repo_kabob.format_owl.catalog_mycatalog.supersede.load
#
# Note, parameters can be listed in any order as long as the filename is terminated with .load
#

function print_usage {
    echo "Usage:"
    echo "$(basename $0) [OPTIONS]"
    echo "  [-d <load request directory>]: MUST BE ABSOLUTE PATH. The path to the load request directory."
    echo "  [-p <blazegraph properties file>]: MUST BE ABSOLUTE PATH. The path to the blazegraph properties file."
    echo "  [-m <maven>]: MUST BE ABSOLUTE PATH. The path to the mvn command."
    echo "  [-c <blazegraph war classpath directory]: MUST BE ABSOLUTE PATH. The path to the blazegraph war lib/ directory."
}

while getopts "c:d:p:m:h" OPTION; do
    case $OPTION in
        # the path to the blazegraph properties file
        d) LOAD_REQUEST_DIRECTORY=$OPTARG
           ;;
        # the path to the blazegraph properties file
        p) BLAZEGRAPH_PROPERTIES_FILE=$OPTARG
           ;;
        # The path to the Apache Maven command
        m) MAVEN=$OPTARG
           ;;
        # HELP!
        h) print_usage; exit 0
           ;;
    esac
done

if [[ -z ${LOAD_REQUEST_DIRECTORY} || -z ${BLAZEGRAPH_PROPERTIES_FILE} || -z ${MAVEN} ]]; then
    echo "load request directory: ${LOAD_REQUEST_DIRECTORY}"
	echo "blazegraph properties file: ${BLAZEGRAPH_PROPERTIES_FILE}"
	echo "maven: ${MAVEN}"
    print_usage
    exit 1
fi

chown jetty:jetty ${LOAD_REQUEST_DIRECTORY}

inotifywait -m ${LOAD_REQUEST_DIRECTORY} -e create,moved_to,attrib |
    while read path action file; do
        echo "The file '$file' appeared in directory '$path' via '$action'"
        if [[ "$file" == *.load ]]
	then
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
		case $param in
		    format_*)
			FORMAT=${param#"format_"}
			;;
		    repo_*)
			REPO_NAME=${param#"repo_"}
			;;
		esac
	    done

	    # check to make sure all required parameters have a value
	    if [[ -z "$REPO_NAME" || -z "$FORMAT" ]]; then
		echo "Load file missing either the AllegroGraph port or repository name (or both). 
                      Please make sure the .port_[PORT] and .repo_[REPONAME] suffixes are part of 
                      the load file name to indicate the Allegrograph port and repository name, respectively."
		exit 1
	    fi

        ## find the directory where the blazegraph lib/ directory deployed
#        CP_DIR=$(grep bigdata.war /var/log/supervisor/blazegraph_process.err.log | cut -f 2 -d "{" | cut -f 2 -d "," | cut -f 3- -d "/")
#        echo "Blazegraph lib/ directory deployed to: ${CP_DIR}WEB-INF/lib"
#        JARS=$(ls ${CP_DIR}WEB-INF/lib/*.jar | tr -s '\n' ':')
#        load_command="java -Dlog4j.configuration=file:///log4j.properties -cp ${JARS} com.bigdata.rdf.store.DataLoader -verbose -format rdfxml ${BLAZEGRAPH_PROPERTIES_FILE} $(head -n 1 ${path}${file})"

        # prior to the load, the Blazegraph web UI (run via Jetty) must be shut down.
        # Only one process can access the Blazegraph journal file at a time.
        # After the load Jetty should be restarted.
        jetty_shutdown_command="java -DSTOP.KEY=KEY -DSTOP.PORT=2222 -jar /usr/local/jetty/start.jar --stop"
        load_command="/kabob.git/scripts/loader/blazegraph/run-loader.sh -z /log4j.properties -g file://$(head -n 1 ${path}${file}) -f ${FORMAT} -r ${REPO_NAME} -p ${BLAZEGRAPH_PROPERTIES_FILE} -m ${MAVEN} -l $(head -n 1 ${path}${file})"
        jetty_restart_command="supervisorctl -c /etc/supervisord.conf restart bg:"

	    echo "EXECUTING LOAD COMMAND: $load_command" 
	    
	    su -c "${jetty_shutdown_command} && ${load_command} && ${jetty_restart_command}" | tee ${path}${file}.log

	    echo "======================================================================"
	    echo "============= Load complete. Jetty/Blazegraph restarted. ============="
	    echo "======================================================================"

	    if [[ ${PIPESTATUS[0]} == 0 ]]
	    then
		touch ${SUCCESS_FILE}
	    else
		touch ${FAIL_FILE}
	    fi
	fi
    done

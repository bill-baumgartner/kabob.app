#!/bin/bash
#
# This script runs the Virtuoso bulk loader.
echo "RUNNING VIRTUOSO BULK LOADER"
/usr/local/virtuoso-opensource/bin/isql-v 1111 dba dba exec="rdf_loader_run();" &
wait
/usr/local/virtuoso-opensource/bin/isql-v 1111 dba dba exec="checkpoint;"
/usr/local/virtuoso-opensource/bin/isql-v 1111 dba dba exec="select * from DB.DBA.load_list;"


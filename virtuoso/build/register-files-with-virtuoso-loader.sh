#!/bin/bash
#
# This script takes as input a single file that contains a list of RDF files.
# For each RDF file in the list, this script registers it with the Virtuoso bulk loader.

while read f; do
   path=$(dirname $f)
   file=$(basename $f)
   echo "Registering file with Virtuoso loader: path=$path file=$file"
  /usr/local/virtuoso-opensource/bin/isql-v 1111 dba dba exec="ld_dir('$path', '$file', 'file://$path/$file');"
  /usr/local/virtuoso-opensource/bin/isql-v 1111 dba dba exec="select * from DB.DBA.load_list;"
done < $1



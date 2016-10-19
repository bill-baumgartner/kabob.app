#!/bin/bash
#
# Spins up 5 docker containers to generate ICE RDF for NCBI taxonomy
# code 9606 (human).
#
# This script inspired by:
# http://kimh.github.io/blog/en/docker/using-docker-to-run-cucumber-tests-in-parallel/
#

TAX="-t 9606"

declare -a DATASOURCES=("HGNC,NCBIGENE_GENEINFO,NCBIGENE_REFSEQUNIPROTCOLLAB,GOA_HUMAN,HP_ANNOTATIONS_ALL_SOURCES"
"IREFWEB_HUMAN_ONLY"
"REFSEQ_RELEASECATALOG,NCBIGENE_GENE2REFSEQ"
"UNIPROT_SWISSPROT"
"UNIPROT_IDMAPPING")

DID=""
COUNTER=1
for ds in "${DATASOURCES[@]}"
do
    echo "Starting kabob-base container to process: $ds"
    DID=$DID" "`docker run -d --name "rdf_gen_$COUNTER" --volumes-from kabob_data ccp/kabob-base:0.1 ./ice-rdf-gen.sh "$TAX" "$ds" "$COUNTER"`
    COUNTER=$((COUNTER + 1))
done
docker wait $DID
docker rm $DID

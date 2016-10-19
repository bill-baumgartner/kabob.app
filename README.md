# kabob.app
Install, build, and run a KaBOB instance via Docker

## The KaBOB Knowledge Base Of Biology
The KaBOB Knowledge Base of Biology is a formal integration of biological knowledge using Semantic Web standards. Its knowledge is grounded in the community-curated [Open Biomedical Ontologies](http://obofoundry.org/), and it uses this ontological foundation to integrate information mined from a collection of biomedical databases with a concerted effort to model biology separate from database content. More information about KaBOB is available at the [KaBOB GitHub page](https://github.com/UCDenver-ccp/kabob). The original publication describing KaBOB in detail is:
> KaBOB: Ontology-Based Semantic Integration of Biomedical Databases <br />
> Kevin M Livingston, Michael Bada, William A Baumgartner Jr., and Lawrence E Hunter <br />
> [BMC Bioinformatics. 2015 Apr 23;16:126. doi: 10.1186/s12859-015-0559-3](http://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-015-0559-3). PubMedId:[25903923](https://www.ncbi.nlm.nih.gov/pubmed/25903923)

This project facilitates the installation and construction of a KaBOB instance via [Docker](https://www.docker.com/).

## Caveats
1. The current build procedure requires the use of the [AllegroGraph](http://franz.com/agraph/allegrograph/) graph database, and thus requires a license for AllegroGraph. Without a license, the default triple limit of AllegroGraph will cause the build to terminate prematurely.
2. This project is set up to build an instance of KaBOB based on human data. Future extensions of this project will parameterize the species on which KaBOB instances can be based.

## How to install KaBOB using AllegroGraph as a backend

### Initial setup
1. Install [Docker](https://www.docker.com/) on the machine that will host KaBOB
2. Download this repository: 

   ```sh
   git clone https://github.com/bill-baumgartner/kabob.app ./kabob.app.git
   ```
3. Follow the instructions in `kabob.app.git/allegrograph/build/config/user-env.sh.example` to create a `user-env.sh` file with your AllegroGraph license.

   > At this point, the KaBOB build is ready to proceed via a succession of Docker commands. 

### Download datasources and generate RDF
4. Create a Docker volume where the downloaded data files and generated RDF will be stored: 
   ```sh
   docker create -v /kabob_data --name kabob_data ubuntu:latest
   ```
5. Initial setup (downloads ontologies used by KaBOB): 
   ```sh
   docker run --rm --volumes-from kabob_data ccp/kabob-base:0.1 ./setup.sh
   ```
6. Create data source RDF (downloads and processes publicly available databases). If the KaBOB host machine is a Unix-based OS, then run `kabob.app.git/scripts/human-ice-rdf-gen.sh`. Note, this script spins up five Docker containers to download and process data sources. Doing so will consume at least 5 cores, so make sure the host machine is capable. If you are on a non-Unix machine, then you will need to execute the following 5 Docker commands and wait for them to complete:
   ```sh
   docker run -d --name "rdf_gen_1" --volumes-from kabob_data ccp/kabob-base:0.1 ./ice-rdf-gen.sh "-t 9606" "HGNC,NCBIGENE_GENEINFO,NCBIGENE_REFSEQUNIPROTCOLLAB,GOA_HUMAN,HP_ANNOTATIONS_ALL_SOURCES" "1"
   
   docker run -d --name "rdf_gen_2" --volumes-from kabob_data ccp/kabob-base:0.1 ./ice-rdf-gen.sh "-t 9606" "IREFWEB_HUMAN_ONLY" "2"
   
   docker run -d --name "rdf_gen_3" --volumes-from kabob_data ccp/kabob-base:0.1 ./ice-rdf-gen.sh "-t 9606" "REFSEQ_RELEASECATALOG,NCBIGENE_GENE2REFSEQ" "3"
   
   docker run -d --name "rdf_gen_4" --volumes-from kabob_data ccp/kabob-base:0.1 ./ice-rdf-gen.sh "-t 9606" "UNIPROT_SWISSPROT" "4"
   
   docker run -d --name "rdf_gen_5" --volumes-from kabob_data ccp/kabob-base:0.1 ./ice-rdf-gen.sh "-t 9606" "UNIPROT_IDMAPPING" "5"
   ```

    > Data source download and RDF generation will take ~2 hours to complete.

### Setup and start AllegroGraph
7. Create a Docker volume where AllegroGraph will store its data: 
   ```sh
   docker create --name agraph-data franzinc/agraph-data
   ```
8. Build the Docker image (this will import the AllegroGraph Docker image): 
   ```sh
   docker build -t ccp/agraph:v6.1.1 allegrograph/build/
   ```
9. Populate two Docker volumes with required code:
   ```sh
   docker run --rm -v $(pwd):/backup ccp/kabob-base:0.1 tar czvf /backup/kabob.git-backup.tar.gz /kabob.git
   docker create -v /kabob.git --name kabob.git ubuntu:latest
   docker run --rm --volumes-from kabob.git -v $(pwd):/backup ubuntu:latest bash -c "cd /kabob.git && tar xzvf /backup/kabob.git-backup.tar.gz --strip 1"
   rm kabob.git-backup.tar.gz
   ```
   ```sh
   docker run --rm -v $(pwd):/backup ccp/kabob-base:0.1 tar czvf /backup/m2-backup.tar.gz /root/.m2
   docker create -v /root/.m2 --name m2 ubuntu:latest
   docker run --rm --volumes-from m2 -v $(pwd):/backup ubuntu bash -c "cd /root/.m2 && tar xzvf /backup/m2-backup.tar.gz --strip 2"
   rm m2-backup.tar.gz
   ```
10. Start up AllegroGraph
    ```sh
    docker run -d -p 10000-10035:10000-10035 \
    --volumes-from agraph-data --volumes-from kabob_data --volumes-from kabob.git --volumes-from m2 \
    --name agraph ccp/agraph:v6.1.1
    ```  
    > At this point, AllegroGraph should be running and its WebView UI should be visible at http://[HOST_URL]:10035, where [HOST_URL] is the URL for the machine hosting KaBOB.

### Build KaBOB
11. Build KaBOB using the RDF generated from downloaded data sources:
    ```sh
    docker exec agraph bash -c "/kabob.git/scripts/docker/build-from-scratch.sh"
    ```
   
   

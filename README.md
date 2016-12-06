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
3. The scripts in this project assume that the host machine is Unix-based

## How to install KaBOB using AllegroGraph as a backend

### Initial setup
1. Install [Docker](https://www.docker.com/) on the machine that will host KaBOB
2. Download this repository: 

   ```sh
   git clone --branch v0.2 https://github.com/bill-baumgartner/kabob.app ./kabob.app.git
   ```
3. Follow the instructions in `kabob.app.git/allegrograph/build/config/user-env.sh.example` to create a `user-env.sh` file with your AllegroGraph license.

   > At this point, the KaBOB build is ready to proceed via a succession of scripts that call Docker commands. All scripts should be run from the base directory of the project: `cd kabob.app.git`

### BUILD STEP 1: Download datasources and generate RDF
Run: `scripts/step1_rdf-gen.sh n` where _n_ is the number of docker containers (1-5) that will be used to generate RDF. _n_ should be <= the number of cores available on your machine. 

   > This step may take >90 min.

   > NOTE: The so.owl PURL is currently broken (as of Dec 5th, 2016). In order to proceed further you must manually download so.owl to the /kabob_data volume. To do so, run the following command: `docker exec agraph bash -c "cd /kabob_data/ontology;wget https://raw.githubusercontent.com/The-Sequence-Ontology/SO-Ontologies/master/releases/so-xp.owl/so-xp.owl;rm so.owl"`

### BUILD STEP 2: Setup and start AllegroGraph
Run: `scripts/step2_ag-setup.sh`

   > At this point, AllegroGraph should be running and its WebView UI should be visible at http://[HOST_URL]:10035, where [HOST_URL] is the URL for the machine hosting KaBOB. Access credentials for logging into AllegroGraph can be found in the [default AllegroGraph configuration file](https://github.com/franzinc/docker-agraph/blob/master/agraph.cfg) (See the SuperUser line).

### BUILD STEP 3: Build KaBOB
Run: `scripts/step3_build-kabob.sh`

   > Building the human KaBOB instance should take ~100 minutes. If you would like to follow along via the agraph logs you can login to the agraph container using `docker exec -ti agraph bash` and then view the agraph log output using `tail -f /tmp/agraph_load_check---supervisor-MKGnli.log` (note the name of the log file may be slightly different)
   
   

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
   git clone https://github.com/bill-baumgartner/kabob.app ./kabob.app.git
   ```
3. Follow the instructions in `kabob.app.git/allegrograph/build/config/user-env.sh.example` to create a `user-env.sh` file with your AllegroGraph license.

   > At this point, the KaBOB build is ready to proceed via a succession of scripts that call Docker commands.

   > All scripts should be run from the base directory of the project:

    ```sh
    cd kabob.app.git
    ```

### BUILD STEP 1: Download datasources and generate RDF
Run:
   ```sh
   scripts/step1_rdf-gen.sh
   ```
   > Note, this script spins up five Docker containers to download and process data sources. Doing so will consume at least 5 cores, so make sure the host machine is capable or adjust accordingly.

### BUILD STEP 2: Setup and start AllegroGraph
Run: 
   ```sh
   scripts/step2_ag-setup.sh
   ```

   > At this point, AllegroGraph should be running and its WebView UI should be visible at http://[HOST_URL]:10035, where [HOST_URL] is the URL for the machine hosting KaBOB.

### BUILD STEP 3: Build KaBOB
Run:
   ```sh
   scripts/step3_build-kabob.sh
   ```
   
   

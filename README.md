# recover-s3-synindex

## Purpose
This repository helps index S3 objects in Synapse from a S3 bucket attached to a Synapse project/folder. The code is written in R and offers two methods for running the pipeline:

1. Executing the code in an R environment, e.g., RStudio in an EC2 instance (see [Method 1: Running in an R Environment](#method-1-running-in-an-r-environment))
2. Running the pipeline using a Docker container for easy setup and portability (see [Method 2: Running with Docker](#method-2-running-with-docker))

## Prerequisites

- Synapse account with relevant access permissions
- Synapse authentication token

A Synapse authentication token is required for use of the Synapse APIs and CLI client. For help with Synapse, Synapse APIs, Synapse authentication tokens, etc., please refer to the [Synapse documentation](https://help.synapse.org/docs/).

## Installation & Usage

### Method 1: Running in an R Environment

#### Setup your environment

1. Provision an EC2 Rstudio Notebook instance
2. Upgrade pip in the terminal of the EC2 instance with `python -m pip install --upgrade pip`
3. Install the Synapse CLI client in the terminal with `pip install synapseclient`

Note: If you are having issues during installation of the Synapse CLI client, consider upgrading pip with `python -m pip install --upgrade pip` before attempting to reinstall `synapseclient`. If you still have issues, force re-install `synapseclient` from the terminal via `pip install --upgrade --force-reinstall synapseclient`.

4. Create a `.Renviron` file in the home folder with the environment variable `SYNAPSE_AUTH_TOKEN='<personal-access-token>'`. Replace `<personal-access-token>` with your actual token. Your personal access token should have **View, Modify and Download** permissions. If you don't have a Synapse personal access token, refer to the instructiocs here to get a new token: [Personal Access Token in Synapse](https://www.synapse.org/#!PersonalAccessTokens:).

#### Setup SSM Access to the S3 bucket

5. Please follow the instructions to [Create a Synapse personal access token (for AWS SSM Access)](https://sagebionetworks.jira.com/wiki/spaces/SC/pages/938836322/Service+Catalog+Provisioning#Create-a-Synapse-personal-access-token) 
6. Please follow instructions 3-5 to set up [SSM Access to an Instance](https://sagebionetworks.jira.com/wiki/spaces/SC/pages/938836322/Service+Catalog+Provisioning#SSM-access-to-an-Instance). (Note: AWS CLI version that is installed on the EC2 offering is ver 2.x)

Note: After setting this step, you should be able to run data_sync.R, i.e be able to sync data between two buckets, and also from a bucket to the local EC2 instance.

#### Clone the repo and install required R libraries

7. Clone this repository and switch to the new project
8. Modify the parameters in [params.R](params.R)
9. Run [install_requirements.R](install_requirements.R)
10. Start a new R session (type `q()` in the R console)

#### Run the ingress pipeline
10. Run [ingress_pipeline.sh](ingress_pipeline.sh) in the terminal using the command `bash ~/<path to>/ingress_pipeline.sh`
11. Set up [ingress_pipeline.sh](ingress_pipeline.sh) on a cronjob of your required frequency

### Method 2: Running with Docker

1. Pull the docker image with `docker pull ghcr.io/sage-bionetworks/recover-s3-synindex`
2. Run a container with `docker run -e AWS_TOKEN=<aws-cli-token> -e SYNAPSE_AUTH_TOKEN=<synapse-auth-token> <image-name>`
3. If desired, setup a scheduled job (AWS Scheduled Jobs, cron, etc.) using the docker image (ghcr.io/sage-bionetworks/recover-s3-synindex) to run the pipeline at your desired frequency

Note: Replace `<aws-cli-token>` and `<synapse-auth-token>` with the actual token values. When provisioning a Scheduled Job, `<aws-cli-token>` and `<synapse-auth-token>` should be specified in the `Secrets` and/or `EnvVars` fields of the provisioning settings page.

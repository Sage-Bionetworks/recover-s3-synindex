library(synapser)
library(arrow)
library(dplyr)

synapser::synLogin(authToken = Sys.getenv('SYNAPSE_AUTH_TOKEN'))

SCRIPT_PROCESS <- 'sts_synindex'
PARQUET_BUCKET <- 'recover-processed-data'
PARQUET_BUCKET_BASE_KEY <- 'main/parquet'
PARQUET_FOLDER <- "syn51406699"
AWS_PARQUET_DOWNLOAD_LOCATION <- './temp_aws_parquet'
SYNAPSE_PARENT_ID <- 'syn51406699'

# Get STS credentials
token <- synapser::synGetStsStorageToken(
  entity = PARQUET_FOLDER,
  permission = "read_only",
  output_format = "json")

if (PARQUET_BUCKET==token$bucket && PARQUET_BUCKET_BASE_KEY==token$baseKey) {
  base_s3_uri <- paste0('s3://', token$bucket, '/', token$baseKey)
} else {
  base_s3_uri <- paste0('s3://', PARQUET_BUCKET, '/', PARQUET_BUCKET_BASE_KEY)
}

# configure the environment with AWS token
Sys.setenv('AWS_ACCESS_KEY_ID'=token$accessKeyId,
           'AWS_SECRET_ACCESS_KEY'=token$secretAccessKey,
           'AWS_SESSION_TOKEN'=token$sessionToken)

sync_cmd <- glue::glue('aws s3 sync {base_s3_uri} {AWS_PARQUET_DOWNLOAD_LOCATION} --exclude "*owner.txt*" --exclude "*archive*"')
system(sync_cmd)

SYNAPSE_AUTH_TOKEN <- Sys.getenv('SYNAPSE_AUTH_TOKEN')
manifest_cmd <- glue::glue('SYNAPSE_AUTH_TOKEN="{SYNAPSE_AUTH_TOKEN}" synapse manifest --parent-id {SYNAPSE_PARENT_ID} --manifest ./current_manifest.tsv {AWS_PARQUET_DOWNLOAD_LOCATION}')
system(manifest_cmd)

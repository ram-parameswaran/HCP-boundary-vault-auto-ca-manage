#! /usr/bin/env bash

set -eEuo pipefail

usage() {
  cat <<EOF
This script is a helper for setting a channel iteration in HCP Packer
Usage:
   $(basename "$0") <bucket_name> <channel_name>
---
Requires the following environment variables to be set:
 - HCP_CLIENT_ID
 - HCP_CLIENT_SECRET
 - HCP_ORGANIZATION_ID
 - HCP_PROJECT_ID
EOF
  echo "ERROR: Missing env vars org: $HCP_ORGANIZATION_ID proj: $HCP_PROJECT_ID ID: $HCP_CLIENT_ID sec: $HCP_CLIENT_SECRET"
  exit 1
}

# Entry point
test "$#" -eq 2 || usage

bucket_name="$1"
channel_name="$2"
base_url="https://api.cloud.hashicorp.com/packer/2023-01-01/organizations/$HCP_ORGANIZATION_ID/projects/$HCP_PROJECT_ID"

# Authenticate
response=$(curl --location "https://auth.idp.hashicorp.com/oauth2/token" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "client_id=$HCP_CLIENT_ID" \
  --data-urlencode "client_secret=$HCP_CLIENT_SECRET" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "audience=https://api.hashicorp.cloud")
api_error=$(echo "$response" | jq -r '.error')
if [ "$api_error" != null ]; then
  echo "Failed to get access token: $api_error"
  exit 1
fi
bearer=$(echo "$response" | jq -r '.access_token')

# Get Bucket info, create it if it doesnt exist
api_error=$(curl --request GET --silent \
  --url "$base_url/buckets/$bucket_name" \
  --header  "authorization: Bearer $bearer" | jq -r '.message')
if [ "$api_error" != null ]; then
# Bucket likely doesn't exist, create it
  api_error=$(curl --request PUT --silent \
    --url "$base_url/buckets" \
    --data "{\"name\":\"$bucket_name\"}" \
    --header "authorization: Bearer $bearer" \
    --header "Content-Type: application/json" | jq -r '.message')
    if [ "$api_error" != null ]; then
    echo "Error creating bucket: $api_error"
    exit 1
  fi
fi

# Get channel info, create if doesn't exist
api_error=$(curl --request GET --silent \
  --url "$base_url/buckets/$bucket_name/channels/$channel_name" \
  --header  "authorization: Bearer $bearer" | jq -r '.message')
if [[ "$api_error" =~ "Error" ]]; then
# Channel likely doesn't exist, create it
  api_error=$(curl --request POST --silent \
    --url "$base_url/buckets/$bucket_name/channels" \
    --data "{\"name\":\"$channel_name\"}" \
    --header "authorization: Bearer $bearer" \
    --header "Content-Type: application/json" | jq -r '.message')
  if [ "$api_error" != null ]; then
    echo "Error creating channel: $api_error"
    exit 1
  fi
fi
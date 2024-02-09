#! /usr/bin/env bash

set -eEuo pipefail

usage() {
  cat <<EOF
This script is a helper for setting a channel iteration in HCP Packer
Usage:
   $(basename "$0") <channel_name> <iteration_id> <bucket_name>
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
test "$#" -eq 3 || usage

bucket_name="$1"
channel_name="$2"
version="$3"
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

echo "iteration id: $version"

# Update channel to point to version
api_error=$(curl --request PATCH --silent \
  --url "$base_url/buckets/$bucket_name/channels/$channel_name" \
  --data '{"version_fingerprint":"'"$version"'", "update_mask":"versionFingerprint"}' \
  --header "authorization: Bearer $bearer" \
  --header "Content-Type: application/json" | jq -r '.message')
  echo $api_error
if [ "$api_error" != null ]; then
    echo "Error updating version: $api_error"
    exit 1
fi



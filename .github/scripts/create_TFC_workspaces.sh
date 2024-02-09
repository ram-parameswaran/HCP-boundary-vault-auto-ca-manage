#! /usr/bin/env bash

set -eEuo pipefail

usage() {
  cat <<EOF
This script is a helper for setting up TFC workspaces
Usage:
   $(basename "$0") <tfc_token> <tfc_org_id> <workspace_list>
---
Requires the following environment variables to be set:
 - TFC_TOKEN
 - TFC_ORG
 - GHREPO
 - GHBRANCH
 - WROKSPACE_ARRAY
EOF
  echo "ERROR: Missing env vars"
  exit 1
}

# Entry point
test "$#" -eq 7 || usage

TFC_TOKEN="$1"; shift
TFC_ORG="$1"; shift
GHREPO="$1"; shift
GHBRANCH="$1"; shift
ARRAY=("$@")

base_url="https://app.terraform.io/api/v2/organizations/$TFC_ORG"
echo $base_url

# Check to see if the org exists
echo "Checking to see if workspace exists"
check_workspace_result=$(curl -s --header "Authorization: Bearer $TFC_TOKEN" "$base_url")
echo $check_workspace_result | jq

# itterate over array to create workspaces
for i in "${ARRAY[@]}"
do
  # Check to see if the workspace already exists
  echo "$i"
  echo "Checking to see if workspace exists"
  check_workspace_result=$(curl -s --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" "$base_url/workspaces/${i}")
  echo $check_workspace_result | jq

# Parse workspace_id from check_workspace_result
  workspace_id=$(echo $check_workspace_result | jq -r '.data.id')
  echo ""
  echo "Workspace ID: " $workspace_id

# Create workspace if it does not already exist
  if [ "$workspace_id" = "null" ]; then
   echo ""
   echo "Workspace did not already exist; will create it."
   jq -n --arg name "$i" --arg repository "$GHREPO" --arg branch "$GHBRANCH" '{"data": { "attributes": {"name": $name, "resource-count": "0"}, "type": "workspaces" }}' > workspace.json
   workspace_result=$(curl -s --header "Authorization: Bearer $TFC_TOKEN" \
   --header "Content-Type: application/vnd.api+json" --request POST \
   --data @workspace.json "$base_url/workspaces")
   echo $workspace_result | jq

    # Parse workspace_id from workspace_result
    workspace_id=$(echo $workspace_result | jq -r '.data.id')
    echo ""
    echo "Workspace ID: " $workspace_id
  else
    echo ""
    echo "Workspace already existed."
  fi
done
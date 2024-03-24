### HCP-boundary-vault-auto-ca-manage
Framework to use HCP tooling to manage AMI's CA auth from boundary via vault driven byy github actions and Terraform

## Outcomes:
This configures:
- HCP Vault 
    - ssh auth method 
    - kvv2 to store the public key in
- HCP Boundary 
    - test org 
    - project
    - host catalog
    - credential store
    - test users
- Terraform 
    - 3 x Workspaces
- Packer
    - Project
    - Channel
    - Version
- AWS
    - 3 x t2 micro EC2's built with packer AMI

## Flow:
Github actions drives:
- Terraform sets up SSH auth method, setup a kvv2 store and store the private key in it
- Vault action retrieves private key for use in action pipeline 
- Packer builds image containing SSH private key for SSH ca auth
- Image is uploaded/dated in AWS AMI store
- Terraform sets up Boundary and Vault cred association
- Terraform Boundary credentials store 
- Terraform setups Boundary users
- Terraform setup some t2 micro ec2's for testing

## Setup / Use:
- Fork the repository
- Setup the [Github actions secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) 
- push (PR) a minor change to the repo
- watch action for completion
- you will be able to boundary auth then ssh to one of your AWS instances 

# AWS setup:
- Create [Github actions secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) for:
    - AWS_ACCESS_KEY_ID
    - AWS_REGION
    - AWS_SECRET_ACCESS_KEY

# HCP setup:
- Create [Github actions secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) for:
    - HCP_CLIENT_ID
    - HCP_CLIENT_SECRET
    - HCP_ORGANIZATION_ID
    - HCP_PROJECT_ID

note:
as per [Create HCP service principal and set env var](https://developer.hashicorp.com/packer/tutorials/hcp-get-started/hcp-push-artifact-metadata#create-hcp-service-principal-and-set-to-environment-variable)

# Terraform cloud setup:
- need to use an team owner token for access
- this will auto magically setup 3 workspaces for use with this action, repo name prefaced by action it's used by
- need to use workspace and organisation human readable names not ID's in secrets
- Create [Github actions secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) for:
    - TF_API_TOKEN
    - TF_ORG_API_TOKEN

In addition to the secrets you also need to setup the following Github action [variables](https://docs.github.com/en/actions/learn-github-actions/variables#creating-configuration-variables-for-a-repository)

- TF_CLOUD_ORGANIZATION = the neame of your TF cloud organisation
- TF_SSH_SETUP_WORKSPACE = HCP-boundary-vault-auto-ca-manage
- TF_BOUNDARY_SETUP_WORKSPACE = HCP-boundary-vault-boundary_setup
- TF_INFRA_SETUP_WORKSPACE = HCP-boundary-vault-infra_setup

# HCP Vault setup:
- Create [Github actions secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) for:
    - VAULT_ADDR
    - VAULT_TOKEN

note: 
You need an orphaned token for Terraform to use for this. To create it use the following and if not testing, set the policy appropriately:
```
NAMESPACE=admin vault token create -policy=hcp-root -period=1440h -orphan
```

# HCP Packer setup:
- Ensure you have a "free registry" created in HCP packer
- The script will create a bucket named as your repo and a channel based of your branch name if it doesn't already exist

# HCP Boundary setup
- Create [Github actions secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) for:
    - BOUNDARY_ADDR
    - BOUNDARY_PASS
    - BOUNDARY_USER
    
note: 
The boundary user needs to be root or have root equivalent permissions

## Boundary workflow

Note: the `keyring-type` flag may not be necessary depending on your OS keyring configuration

```
boundary authenticate -keyring-type="secret-service"
boundary connect ssh -host-id <host id> -target-id <target id> -keyring-type="secret-service
```

## Planned improvements:
- Use Vault namespaces
- move all possible secrets to Vault
- Implement terraform Cloud secrets engine
- tag AMI's with project name and add to Boundary host set filter
- Setup session recording

## Acknowledgements:

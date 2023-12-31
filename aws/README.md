# AWS Terraform k8s Setup Instructions

## AWS CLI Setup

To access AWS services with the AWS CLI, you need an AWS account and IAM credentials. Ensure you have the following prerequisites in place:

- [AWS CLI Version 2 Prerequisites](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html)

Install the AWS CLI:

- [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

#### Authenticate the CLI with your AWS credentials or through SSO:

```bash
aws configure
# or
aws configure sso
```

#### Set Your AWS Profile Name

To determine your AWS profile name, run the following command:

```bash
aws configure list-profiles
```

Using the profile name, define your AWS Profile:

```bash
aws sts get-caller-identity --profile YOUR_PROFILE_NAME
```

### Terraform and Terragrunt Installation

If you haven't installed Terraform and Terragrunt yet, follow these steps:

#### Install Terraform
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Install Terragrunt
```bash
brew install terragrunt
```

### Cluster Configuration
There are two predefined cluster setups available:

#### Multi Cluster

Creates three Kubernetes clusters for prod, non-prod, and management. This setup is recommended for best practices. To set up a multi-cluster, use the "multi-cluster-setup" folder.

#### Single Cluster
Creates only one Kubernetes cluster, which is recommended for demos and lean setups. To set up a single cluster, use the "single-cluster-setup" folder.

### Configuration Settings

In both the "multi-cluster-setup" and "single-cluster-setup" folders, you'll find a YAML file called common_vars.yaml. Configure the following fields within that file for your chosen cluster setup:

Configure the following fields:
* project_name: "PROJECT_NAME" (Choose any name)
* tf_state_bucket: "TF_STATE_BUCKET" (Choose any name)
* profile: "PROFILE_NAME" (Run `aws configure list-profiles` to fetch your AWS profile)
* region: "REGION_CODE" (Choose your cluster's region, e.g., us-east-1)

### Run setup
Go into the **eks** folder inside the folder of your chosen cluster setup, and apply the following command to run the terraform setup of your cluster:
```bash
terragrunt run-all apply
```
The command may take between 15-30 minutes to complete, depending on your cluster configuration.

### Kubectl
After terragrunt is finished successfully, to install `kubectl` and enable local `kubectl` access to your AWS EKS cluster:

```bash
aws eks update-kubeconfig --region REGION_CODE --name PROJECT_NAME --profile YOUR_PROFILE_NAME
```
Make sure to replace REGION_CODE, PROJECT_NAME, and YOUR_PROFILE_NAME with your specific values that were used in your YAML file.

## Github Actions Setup 
The following instructions will allow Github actions to push images into the AWS image repo:

### Set your AWS region and IAM user name
```bash
AWS_REGION="REGION_CODE"
AWS_PROFILE="YOUR_PROFILE_NAME"
IAM_USER_NAME="github-actions"
```
Make sure to replace REGION_CODE, and YOUR_PROFILE_NAME with your specific values that were used in your YAML file.

### Create an IAM user
```bash
echo "Creating IAM user..."
aws iam create-user --user-name $IAM_USER_NAME
```

### Attach policies for ECR and EKS
```bash
echo "Attaching policies to IAM user..."
aws iam attach-user-policy --user-name $IAM_USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess --profile $AWS_PROFILE
aws iam put-user-policy --user-name $IAM_USER_NAME --policy-name EKSKoalaAccessV1 --profile $AWS_PROFILE --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "eks:AccessKubernetesApi",
                "eks:Describe*",
                "eks:List*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}'
```

### Create an access key for the user
```bash
echo "Creating access key..."
credentials=$(aws iam create-access-key --profile $AWS_PROFILE --user-name $IAM_USER_NAME)
```

### Extract access key and secret key
```bash
echo "Put the following secrets in github organization"
access_key=$(echo $credentials | jq -r '.AccessKey.AccessKeyId')
secret_key=$(echo $credentials | jq -r '.AccessKey.SecretAccessKey')
```

OR without jq: 

```json
{
    "AccessKey": {
        "UserName": "github-actions",
        "AccessKeyId": "THE-KEY",
        "Status": "Active",
        "SecretAccessKey": "SECRET",
        "CreateDate": "2023-11-26T21:32:50+00:00"
    }
}
```

### Define Github secrets 
Direct link (Replace with your OrganizationName):

https://github.com/organizations/[OrganizationName]/settings/secrets/actions/new

On this page, add each of the following names/values as a separate key in Github:
```bash
AWS_ACCESS_KEY_ID=AccessKeyId
AWS_SECRET_ACCESS_KEY=SecretAccessKey
```


Before starting, make sure you complete the following:
To access AWS services with the AWS CLI, you need an AWS account and IAM credentials. When running AWS CLI commands, the AWS CLI needs to have access to those AWS credentials. To increase the security of your AWS account, we recommend that you do not use your root account credentials. You should create a user with least privilege to provide access credentials to the tasks you'll be running in AWS.

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html



Install AWS CLI
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


To confirm aws access:
aws sts get-caller-identity
Or
aws iam get-user

In somecases your AWS cli profile isn't default:
Error: Unable to locate credentials. You can configure credentials by running "aws configure"

run with specific profile name:
aws sts get-caller-identity --profile YOUR_PROFILE_NAME

In somecases the problem is an expired token or bad credentials:
error: Error when retrieving token from sso: Token has expired and refresh failed

Action to login (Don't forget to specify profile name in case you need to):
Do you have SSO? aws sso login 
Regular login? aws login

# Run all terragrunt or terrafrom
terragrunt run-all apply


AFTER CREATION
To allow local kubectl to login
aws eks update-kubeconfig --region region-code --name THE_CLUSTER_NAME

Run the following:
project_name: "eyal-startup"
profile: "AdministratorAccess-182885424439"
region: "us-east-1"
# Set your AWS region and EKS cluster name
AWS_REGION="us-east-1"
EKS_CLUSTER_NAME="eyal-startup"

# Set IAM user name
IAM_USER_NAME="github-actions"

# Create an IAM user
echo "Creating IAM user..."
aws iam create-user --user-name $IAM_USER_NAME

# Attach policies for ECR and EKS
echo "Attaching policies to IAM user..."
aws iam attach-user-policy --user-name $IAM_USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
aws iam put-user-policy --user-name $IAM_USER_NAME --policy-name EKSKoalaAccessV1 --policy-document '{
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


# Create access key for the user
echo "Creating access key..."
credentials=$(aws iam create-access-key --user-name $IAM_USER_NAME)

# Extract access key and secret key
echo "Put the following secrets in github organization"
access_key=$(echo $credentials | jq -r '.AccessKey.AccessKeyId')
secret_key=$(echo $credentials | jq -r '.AccessKey.SecretAccessKey')

OR without jq
{
    "AccessKey": {
        "UserName": "github-actions",
        "AccessKeyId": "THE-KEY",
        "Status": "Active",
        "SecretAccessKey": "SECRET",
        "CreateDate": "2023-11-26T21:32:50+00:00"
    }
}

Define github secrets at: 
Replace with your OrganizationName
https://github.com/organizations/[OrganizationName]/settings/secrets/actions/new

AWS_ACCESS_KEY_ID=THE-KEY
AWS_SECRET_ACCESS_KEY=SECRET


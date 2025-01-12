# GCP Terraform k8s Setup Instructions

## GCP CLI Setup

To access GCP services with the gcloud CLI, you need a GCP account and credentials. Ensure you have the following prerequisites in place:

- [Google Cloud SDK Prerequisites](https://cloud.google.com/sdk/docs/install)

Install the Google Cloud SDK:

- [Google Cloud SDK Installation Guide](https://cloud.google.com/sdk/docs/install-sdk)

#### Authenticate the CLI:

```bash
gcloud auth login
gcloud auth application-default login
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
* project_id: "YOUR_PROJECT_ID"
* project_resource_prefix: "YOUR_PROJECT_RESOURCE_PREFIX_THAT_WILL_BE_USED_FOR_ALL_RESOURCES"
* tf_state_bucket: "YOUR_TF_STATE_BUCKET"
* primary_location: "YOUR_PRIMARY_LOCATION"
* locations: ["YOUR_PRIMARY_LOCATION", "YOUR_SECONDARY_LOCATION"]

### Create Bucket in GCS for TF state

```bash
export PROJECT_ID=<your project ID>
gcloud config set project $PROJECT_ID
gcloud storage buckets create gs://$PROJECT_ID-terraform-backend
```

### Run setup
Go into the **gcp/tf** folder inside the folder of your chosen cluster setup, and apply the following command to run the terraform setup of your cluster, example:
```bash
cd gcp/tf/multi-cluster-setup # in case of multi-cluster-setup
```
To provision your clusters and infrastructure, run the following command:
```base
terragrunt run-all apply
```
The command may take between 15-30 minutes to complete, depending on your cluster configuration.

> **Important**: GCP can take a minute or two to enable an API for a project for the first time. If you see errors about APIs not being enabled, wait a minute and re-run the `terragrunt run-all apply` command.

### Run the cluster setup
After terragrunt is finished successfully, please visit [https://docs.koalaops.com/getting-started/basic-setup](https://docs.koalaops.com/getting-started/basic-setup) to continue with setting up your cluster.


# infra-template
Templates for infra setup to share with customers.


### Getting started

1. Copy `tf` dir
2. Find-and-replace PROJECT_NAME with whatever you want
3. Find-and-replace GCP_PROJECT_ID with the exact project ID (not name, in case they are different) where you want the resources to be created.


### Review resources in each env

For a proper production setup it is considered best practice to separate production and non-production workloads, as well as the "control plane" or "management" cluster.

Therefore, by default we create a single prod cluster, single non-prod cluster (any environment such as dev, staging etc will be here), and a management cluster.

Review the `terraform.tfvars` file in each env (e.g. `/tf/env/management/terraform.tfvars`), starting with the management env which also provisions shared resources such as network, image registry etc.

### Create Bucket in GCS for TF state

```
gcloud storage buckets create gs://PROJECT_NAME-terraform-backend
```

### Provision resources

Start with the management cluster:

```shell
cd tf/env/management
terraform init
terraform apply
```

Continue with nonprod and prod clusters:
```shell
cd tf/env/nonprod
terraform init
terraform apply
```

```shell
cd tf/env/prod
terraform init
terraform apply
```

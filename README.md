# infra-template
Templates for infra setup to share with customers.


### Getting started

1. Copy `tf` dir
2. Find-and-replace PROJECT_NAME with whatever you want
3. Find-and-replace PROJECT_ID with the exact project ID (not name, in case they are different) where you want the resources to be created.


### Review resources in each env

For a proper production setup it is considered best practice to separate production and non-production workloads, as well as the "control plane" or "management" cluster.

Therefore, by default we create a single prod cluster, single non-prod cluster (any environment such as dev, staging etc will be here), and a management cluster.

However, for a simpler setup or if you just want to test things before deploying a full production setup,
you can instead create a single cluster which will contain both management-related workloads and any of your own workloads.
To do so simply ignore the `management` `nonprod` and `prod` dirs and use the `single-cluster-setup` dir.

Review the `terraform.tfvars` file in each env (e.g. `/tf/env/management/terraform.tfvars`), starting with the management env which also provisions shared resources such as network, image registry etc.

### Create Bucket in GCS for TF state

```
gcloud storage buckets create gs://PROJECT_ID-terraform-backend
```

### Provision resources

<!-- Important notice -->
Important: GCP can take a minute or two to enable an API for a project for the first time. If you see errors such as:
    
    ```Error creating Repository: googleapi: Error 403: Artifact Registry API has not been used in project my-test-project-404509 before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/artifactregistry.googleapis.com/overview?project=my-test-project-404509 then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.```

Then simply wait a minute and re-run the `terraform apply` command.

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

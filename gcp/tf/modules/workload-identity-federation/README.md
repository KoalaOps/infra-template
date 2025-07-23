# Workload Identity Federation for GitHub Actions

This module sets up a comprehensive Workload Identity Federation configuration to allow GitHub Actions workflows to authenticate with Google Cloud Platform without using service account keys. This implementation is fully declarative and organization-based.

## What it creates

- **Required APIs**: Enables IAM Credentials, STS, Artifact Registry, and Container APIs
- **Workload Identity Pool**: A pool that manages external identity providers
- **Workload Identity Provider**: Configured for GitHub Actions OIDC tokens with organization-level access
- **Service Account**: A dedicated service account for GitHub Actions with comprehensive permissions
- **IAM Bindings**: Proper permissions for the service account and workload identity federation
- **Artifact Registry Repository**: Docker repository for storing container images

## Features

- **Organization-level access**: All repositories in the specified GitHub organization can authenticate
- **Comprehensive permissions**: Includes container, registry, build, storage, logging, and monitoring permissions
- **Automatic API enablement**: Ensures all required Google Cloud APIs are enabled
- **Artifact Registry integration**: Creates a Docker repository for CI/CD workflows

## How to use

1. **Configure your organization**: Update the `github_org` in `common_vars.yaml` with your GitHub organization name:
   ```yaml
   github_org: "your-github-organization"
   ```

2. **Configure location and prefix**: The module uses existing variables from `common_vars.yaml`:
   - `primary_location` - Used for Artifact Registry location
   - `project_resource_prefix` - Used for repository naming (`{prefix}-repo`)

3. **Deploy the infrastructure**:
   ```bash
   # For single-cluster setup
   cd gcp/tf/single-cluster-setup/workload-identity
   terragrunt apply
   
   # For multi-cluster setup
   cd gcp/tf/multi-cluster-setup/workload-identity
   terragrunt apply
   ```

4. **Configure your GitHub Actions workflow**:
   ```yaml
   name: Deploy to GCP
   on:
     push:
       branches: [main]
   
   jobs:
     deploy:
       runs-on: ubuntu-latest
       permissions:
         contents: read
         id-token: write
       
       steps:
         - uses: actions/checkout@v4
         
         - id: 'auth'
           name: 'Authenticate to Google Cloud'
           uses: 'google-github-actions/auth@v2'
           with:
             workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
             service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}
         
         - name: 'Set up Cloud SDK'
           uses: 'google-github-actions/setup-gcloud@v2'
         
         - name: 'Build and push Docker image'
           run: |
             gcloud auth configure-docker ${{ secrets.DOCKER_REGISTRY_URL }}
             docker build -t ${{ secrets.DOCKER_REGISTRY_URL }}/my-app:${{ github.sha }} .
             docker push ${{ secrets.DOCKER_REGISTRY_URL }}/my-app:${{ github.sha }}
   ```

## Getting the configuration values

After deployment, you can get the required values using:

```bash
# Get the workload identity provider
terragrunt output workload_identity_provider

# Get the service account email
terragrunt output service_account

# Get the project number
terragrunt output project_number

# Get the Docker registry URL
terragrunt output docker_registry_url
```

## Security Features

- **Organization-scoped**: Only repositories in the specified GitHub organization can authenticate
- **Comprehensive permissions**: The service account has carefully scoped permissions for CI/CD workflows
- **No long-lived keys**: No service account keys are created or managed
- **Attribute conditions**: Authentication is restricted to the specified GitHub organization
- **Token creator permissions**: Includes necessary token creation permissions for advanced workflows

## Included Permissions

The service account is granted the following roles:
- `roles/container.developer` - For managing containers and Kubernetes
- `roles/container.clusterViewer` - For viewing cluster information
- `roles/artifactregistry.writer` - For pushing images to Artifact Registry
- `roles/storage.admin` - For managing Cloud Storage
- `roles/cloudbuild.builds.editor` - For managing Cloud Build
- `roles/run.admin` - For managing Cloud Run services
- `roles/logging.logWriter` - For writing logs
- `roles/monitoring.metricWriter` - For writing metrics

## Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| project_id | GCP Project ID where resources will be created | string | yes |
| github_org | GitHub organization name to grant access to | string | yes |
| region | Google Cloud location for the Workload Identity Pool | string | yes |
| artifact_registry_location | Location for the Artifact Registry repository | string | yes |
| artifact_registry_repository_name | Name of the Artifact Registry repository | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| project_number | Numeric project number — useful for GitHub Actions auth |
| service_account | Email of the service account to impersonate |
| workload_identity_provider | Full resource name of the Workload Identity Provider |
| artifact_registry_repository | Full name of the created Artifact Registry repository |
| docker_registry_url | Docker registry URL for pushing images | 
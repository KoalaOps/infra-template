# You can provide the project_id and project_name here, 
# or by setting the env variables TF_VAR_project_id and TF_VAR_project_name.
# 
project_id   = "PROJECT_ID"
project_name = "PROJECT_NAME"

# Default cluster name is the project name with "-cluster" appended. You can override it here.
# cluster_name  = "PROJECT_NAME-cluster"

# Default image repo id is the project name with "-repo" appended. You can override it here.
# image_repo_id = "PROJECT_NAME-repo"

regions      = ["us-east1"]
region       = "us-east1"
location     = "us-east1-b"
zone         = "us-east1-b"
node_count   = 3
machine_type = "e2-standard-2"

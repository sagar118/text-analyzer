# Text Analyzer

## Checklist:

* **Problem description**
  * [ ] The problem is well described and it's clear what the problem the project solves
* **Cloud**
  * [x] Project developed on Cloud
  * [x] IaC tools are used for provisioning the infrastructure
* **Experiment tracking and model registry**
  * [x] Experiment tracking
  * [x] Model registry
* **Workflow orchestration**: Fully deployed workflow
  * [x] Development
  * [x] Staging
  * [x] Production
* **Model deployment**
  * [x] The model deployment code is containerized
  * [x] Deployed to cloud
* **Model monitoring**
  * [ ] Comprehensive model monitoring that sends alerts or runs a conditional workflow (e.g. retraining, generating debugging dashboard, switching to a different model) if the defined metrics threshold is violated
* **Reproducibility**
  * [ ] Create a README file with instructions
  * [ ] Steps to execute the code
  * [x] Create virtual environment where version for all the dependencies are specified
* **Best practices**
  * [x] Unit tests
  * [ ] Integration test
  * [x] Linter and/or code formatter are used
  * [x] Makefile
  * [x] pre-commit hooks
  * [x] CI/CD pipeline

```
sudo yum update
sudo yum install git
sudo yum install make
```

## Infrastructure

**Export environment variable**: `export TF_VAR_env = "dev"`

**Commands to run terraform files**:

Terraform Cloud:

* Login to Terraform Cloud: `terraform login`
* Create new workspace: `terraform workspace new <workspace_name>`
* Select workspace: `terraform workspace select <workspace_name>`
* List workspaces: `terraform workspace list`
* Delete workspace: `terraform workspace delete <workspace_name>`
* Show workspace: `terraform workspace show`

```bash
terraform plan -var-file="./modules/vars/dev.tfvars" -var-file="./modules/vars/secrets.tfvars"
terraform apply -var-file="./modules/vars/dev.tfvars" -var-file="./modules/vars/secrets.tfvars"
terraform destroy -var-file="./modules/vars/dev.tfvars" -var-file="./modules/vars/secrets.tfvars"
```


```bash
# Use `-reconfigure` whenever switching between environments

# Development
terraform init -backend-config="key=infrastructure-dev.tfstate" -var-file="./modules/vars/dev.tfvars"
terraform validate
terraform plan -var-file="./modules/vars/dev.tfvars"
terraform apply -var-file="./modules/vars/dev.tfvars"

# Staging
terraform init -backend-config="key=infrastructure-stg.tfstate" -var-file="./modules/vars/stg.tfvars"
terraform validate
terraform plan -var-file="./modules/vars/stg.tfvars"
terraform apply -var-file="./modules/vars/stg.tfvars"

# Production
terraform init -backend-config="key=infrastructure-prod.tfstate" -var-file="./modules/vars/prod.tfvars"
terraform validate
terraform plan -var-file="./modules/vars/prod.tfvars"
terraform apply -var-file="./modules/vars/prod.tfvars"

terraform import -var-file="./modules/vars/dev.tfvars" module.mlops_zc_ta_ec2_role.aws_iam_role.mlops_zc_text_analyzer mlops-zc-text-analyzer
terraform import -var-file="./modules/vars/dev.tfvars" aws_iam_role.mlops_zc_text_analyzer mlops-zc-text-analyzer
terraform import -var-file="./modules/vars/dev.tfvars" modules.ec2.aws_iam_role.mlops_zc_text_analyzer mlops-zc-text-analyzer
```


```bash
psql \
   --host=<HOST> \
   --port=5432 \
   --username=<USERNAME> \
   --password \
   --dbname=<DB_NAME>
```


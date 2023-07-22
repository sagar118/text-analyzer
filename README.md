# Text Analyzer

## Checklist:

* **Problem description**
  * [ ] The problem is well described and it's clear what the problem the project solves
* **Cloud**
  * [ ] Project developed on Cloud
  * [ ] IaC tools are used for provisioning the infrastructure
* **Experiment tracking and model registry**
  * [ ] Experiment tracking
  * [ ] Model registry
* **Workflow orchestration**: Fully deployed workflow
  * [ ] Development
  * [ ] Staging
  * [ ] Production
* **Model deployment**
  * [ ] The model deployment code is containerized
  * [ ] Deployed to cloud
* **Model monitoring**
  * [ ] Comprehensive model monitoring that sends alerts or runs a conditional workflow (e.g. retraining, generating debugging dashboard, switching to a different model) if the defined metrics threshold is violated
* **Reproducibility**
  * [ ] Create a README file with instructions
  * [ ] Steps to execute the code
  * [ ] Create virtual environment where version for all the dependencies are specified
* **Best practices**
  * [ ] Unit tests
  * [ ] Integration test
  * [ ] Linter and/or code formatter are used
  * [ ] Makefile
  * [ ] pre-commit hooks
  * [ ] CI/CD pipeline


## Infrastructure

**Export environment variable**: `export TF_VAR_env = "dev"`

**Commands to run terraform files**:

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
```
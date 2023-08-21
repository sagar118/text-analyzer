# Text Analyzer

This project is a part of the [MLOps Zoomcamp](https://github.com/DataTalksClub/mlops-zoomcamp/tree/main) Project. The aim of the project is to build an end-to-end mlops pipeline.

## Problem Statement

Social Media Texts have been used extensively to understand various events and their impact on the society. In this project we will build a text analyzer that will be able to classify social media text into two categories: `Disastrous` and `Non-Disastrous`. The model is trained on a kaggle dataset from "[Natural Language Processing with Disaster Tweets Competition](https://www.kaggle.com/competitions/nlp-getting-started)".

Classifying tweets as related to natural disasters or not can be valuable for several reasons:

- Early Detection and Response: Social media platforms like Twitter are often used to share real-time information during natural disasters. By classifying tweets, emergency response teams and authorities can quickly identify emerging situations and allocate resources more effectively.

- Situational Awareness: Monitoring tweets can provide insights into the scope, intensity, and impact of a natural disaster. This information can aid in understanding the situation on the ground and making informed decisions.

- Public Safety Alerts: During natural disasters, authorities can use Twitter to send alerts and warnings to affected populations. Accurate classification ensures that relevant alerts reach the right people.

- Resource Allocation: By analyzing tweets, organizations can understand the needs of affected communities and allocate resources such as food, water, medical supplies, and shelter accordingly.

- Disaster Recovery: After a disaster, tweets can provide insights into the ongoing recovery efforts, the needs of survivors, and areas that require additional support.

## Pre-requisites

The following tools are required to run the project:

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Docker](https://docs.docker.com/get-docker/)
- [Python](https://www.python.org/downloads/)

Configure the AWS CLI with your credentials.

You will also need an AWS account, Terraform Cloud account, and Prefect Cloud account.

## Project Directory Structure

There are some files that might be missing from the github directory structure but are created for development purpose and are not pushed to github. These files are:
`workflow.secrets` and `workflow.vars` in the `.github/workflows` directory. These files contain the secrets and variables required for the github actions to run.

```bash
.
├── .github
│   ├── workflows
│   └── workflow.secrets
│   └── workflow.vars
├── Makefile
├── Pipfile
├── Pipfile.lock
├── README.md
├── data
│   ├── raw
│   └── submission.csv
├── deployment
│   ├── Dockerfile
│   ├── Pipfile
│   ├── Pipfile.lock
│   └── app
├── gradio-app
│   └── app.py
├── monitoring
│   ├── config
│   ├── dashboards
│   ├── data
│   ├── docker-compose.yaml
│   ├── evidently_grafana_metrics.py
│   ├── models
│   └── notebooks
├── notebooks
│   ├── exploratory-data-analysis.ipynb
│   └── modeling.ipynb
├── prefect.yaml
├── pyproject.toml
├── terraform
│   ├── main.tf
│   ├── modules
│   ├── outputs.tf
│   └── variables.tf
├── tests
│   ├── integration_tests
│   └── unit_tests
└── training
    ├── prefect.yaml
    ├── re-train.py
    └── utils
```

## Infrastructure

The project is deployed on AWS using the following services:

- [AWS S3](https://aws.amazon.com/s3/) for storing the data and model artifacts.
- [AWS Lambda](https://aws.amazon.com/lambda/) for running the inference code.
- [AWS API Gateway](https://aws.amazon.com/api-gateway/) for creating the API endpoint.
- [AWS ECR](https://aws.amazon.com/ecr/) for storing the docker image.
- [AWS EC2](https://aws.amazon.com/ec2/) for running the training code.
- [AWS IAM](https://aws.amazon.com/iam/) for managing the permissions.
- [AWS RDS](https://aws.amazon.com/rds/) as the MLflow tracking server.

The infrastructure is managed using Terraform. The Terraform code is located in the `terraform` directory.

Below are some terraform cloud comamnds:
* Login to Terraform Cloud: `terraform login`
* Create new workspace: `terraform workspace new <workspace_name>`
* Select workspace: `terraform workspace select <workspace_name>`
* List workspaces: `terraform workspace list`
* Delete workspace: `terraform workspace delete <workspace_name>`
* Show workspace: `terraform workspace show`

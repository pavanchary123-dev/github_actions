📘 Terraform with S3 Remote Backend & GitHub Actions (Learning Project)
📌 Project Overview

This project demonstrates how to:

Use Terraform with a remote S3 backend

Enable state locking using DynamoDB

Run Terraform using GitHub Actions

Choose between Apply or Destroy from the GitHub Actions UI

Cloud Provider: Amazon Web Services (AWS)
CI/CD: GitHub Actions

🏗 Architecture Overview

This project follows production-style best practice:

terraform-project/
│
├── backend/        # Created once (S3 + DynamoDB)
└── infra/          # Infrastructure managed via GitHub Actions
Why Separate Backend?

Backend infrastructure (S3 + DynamoDB) must NOT be destroyed with the main infrastructure.
It should exist independently.

🔹 Step 1 — Create Backend (Run Once Locally)

Navigate to backend folder:

cd backend

Initialize and apply:

terraform init
terraform apply

This creates:

S3 bucket (stores Terraform state)

DynamoDB table (state locking)

After this step, backend is ready.

🔹 Step 2 — Infrastructure Configuration

Inside infra/ folder:

backend.tf
terraform {
  backend "s3" {
    bucket         = "pavanchary-learning-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "learning-terraform-lock"
    encrypt        = true
  }
}
provider.tf
provider "aws" {
  region = "us-east-1"
}
main.tf (Example)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "learning-vpc"
  }
}
🔹 Step 3 — Configure GitHub Secrets

In your repository:

Settings → Secrets and variables → Actions

Add:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

🔹 Step 4 — GitHub Actions Workflow

Location:

.github/workflows/terraform.yml
Workflow with Apply / Destroy Option
name: Terraform Learning

on:
  workflow_dispatch:
    inputs:
      action:
        description: "Choose Terraform Action"
        required: true
        default: "apply"
        type: choice
        options:
          - apply
          - destroy

jobs:
  terraform:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: infra
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
      - name: Terraform Init
        run: terraform init
      - name: Terraform Plan
        run: terraform plan
      - name: Terraform Apply
        if: github.event.inputs.action == 'apply'
        run: terraform apply -auto-approve
      - name: Terraform Destroy
        if: github.event.inputs.action == 'destroy'
        run: terraform destroy -auto-approve
🚀 How To Use

Push code to GitHub

Go to Actions tab

Click Run workflow

Select:

apply → Create infrastructure

destroy → Delete infrastructure

🔐 What This Project Demonstrates

Remote state management

State locking

CI/CD automation

Conditional workflow execution

Infrastructure lifecycle control

🧠 Key Learning Outcomes

✅ Understand Terraform backend configuration
✅ Understand S3 remote state
✅ Understand DynamoDB locking
✅ Understand GitHub Actions manual triggers
✅ Understand safe infrastructure destruction

⚠️ Important Notes

Do NOT manage the backend S3 bucket inside the infra project.

Always keep backend infrastructure separate.
                    ┌─────────────────────────────┐
                    │        GitHub Repository    │
                    │  (infra/ Terraform code)    │
                    └──────────────┬──────────────┘
                                   │
                                   │ Push / Manual Trigger
                                   ▼
                    ┌─────────────────────────────┐
                    │       GitHub Actions        │
                    │  workflow_dispatch input    │
                    │  (apply / destroy)          │
                    └──────────────┬──────────────┘
                                   │
                                   │ AWS Credentials (Secrets)
                                   ▼
                    ┌─────────────────────────────┐
                    │       Terraform CLI         │
                    │  init → plan → apply       │
                    └──────────────┬──────────────┘
                                   │
             ┌─────────────────────┴─────────────────────┐
             │                                           │
             ▼                                           ▼
 ┌─────────────────────────┐                ┌─────────────────────────┐
 │        S3 Bucket        │                │     DynamoDB Table      │
 │ (Remote State Storage)  │                │   (State Locking)       │
 └─────────────────────────┘                └─────────────────────────┘
             │
             ▼
 ┌─────────────────────────────────────────────────────────┐
 │                AWS Infrastructure                       │
 │  VPC / Subnets / EC2 / Security Groups / etc           │
 └─────────────────────────────────────────────────────────┘

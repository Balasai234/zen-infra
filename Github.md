# Terraform + GitHub Actions PR Workflow Notes

## Overall Workflow

This project follows a PR-based GitOps workflow.

Flow:

```text
Feature Branch → Pull Request → Terraform Plan → Merge PR → Terraform Apply
```

Infrastructure is managed using:

* Terraform
* GitHub Actions
* AWS
* Remote backend (S3)
* Optional DynamoDB state locking

---

# Architecture Overview

Resources being created:

* VPC
* Public & Private Subnets
* NAT Gateway
* Route Tables
* EKS Cluster
* EKS Node Group
* RDS PostgreSQL
* ECR Repositories
* IAM Roles & Policies
* Secrets Manager

---

# Important Branching Model

## Never Work Directly on main

Always create a feature branch.

Example:

```bash
git checkout main
git pull origin main
git checkout -b feature/recreate-infra
```

---

# Standard PR Workflow

## Step 1 — Create Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/my-change
```

---

## Step 2 — Make Changes

Examples:

* Terraform changes
* Infrastructure changes
* Pipeline changes
* Empty commit to trigger workflow

---

## Step 3 — Commit Changes

```bash
git add .
git commit -m "My infrastructure change"
```

Empty commit example:

```bash
git commit --allow-empty -m "Trigger workflow"
```

---

## Step 4 — Push Branch

```bash
git push origin feature/my-change
```

---

## Step 5 — Create Pull Request

PR should always be:

```text
feature/my-change → main
```

Inside your own fork repository.

Correct Example:

```text
Balasai234/zen-infra
```

---

# Terraform Plan Process

## Plan Trigger

Terraform Plan runs:

* during PR
* or via workflow_dispatch

Plan only validates changes.

It does NOT create infrastructure.

---

## Expected Output

```text
Plan: X to add, 0 to change, 0 to destroy
```

Example:

```text
Plan: 63 to add, 0 to change, 0 to destroy
```

Meaning:

* Terraform will create 63 resources
* Nothing modified
* Nothing deleted

---

# Merge Process

After successful plan:

1. Open PR
2. Verify checks passed
3. Click:

```text
Merge pull request
```

4. Click:

```text
Confirm merge
```

---

# Terraform Apply Process

## Important

In this project:

Terraform Apply is NOT automatic.

It uses:

```yaml
workflow_dispatch
```

So Apply must be triggered manually.

---

## How To Trigger Apply

Go to:

```text
GitHub → Actions → Terraform Infrastructure
```

Click:

```text
Run workflow
```

Select:

| Field            | Value |
| ---------------- | ----- |
| Branch           | main  |
| Terraform action | apply |

Then click:

```text
Run workflow
```

---

# Deployment Approval Flow

If environments are configured:

Workflow pauses at:

```text
Waiting for approval
```

Steps:

1. Open workflow
2. Click:

```text
Review deployments
```

3. Click:

```text
Approve and deploy
```

Terraform Apply starts.

---

# Terraform Destroy Process

To destroy infrastructure:

Go to:

```text
Actions → Terraform Infrastructure
```

Click:

```text
Run workflow
```

Select:

| Field            | Value   |
| ---------------- | ------- |
| Branch           | main    |
| Terraform action | destroy |

Type:

```text
destroy
```

Then run workflow.

---

# Backend Infrastructure

Terraform uses remote backend.

Backend resources:

## S3 Bucket

Stores:

* terraform.tfstate
* version history

Example:

```text
zen-pharma-terraform-state-balasaicheni
```

---

## DynamoDB Table

Used for state locking.

Prevents:

* multiple concurrent applies
* state corruption

Example:

```text
terraform-locks
```

---

# Important Backend Commands

## Create S3 Bucket

```powershell
aws s3api create-bucket `
  --bucket zen-pharma-terraform-state-balasaicheni `
  --region us-east-1
```

---

## Enable Versioning

```powershell
aws s3api put-bucket-versioning `
  --bucket zen-pharma-terraform-state-balasaicheni `
  --versioning-configuration Status=Enabled
```

---

## Create DynamoDB Table

```powershell
aws dynamodb create-table `
  --table-name terraform-locks `
  --attribute-definitions AttributeName=LockID,AttributeType=S `
  --key-schema AttributeName=LockID,KeyType=HASH `
  --billing-mode PAY_PER_REQUEST `
  --region us-east-1
```

---

# Common Issues

## 1. Workflow Not Triggering

Reason:

* Actions disabled
* workflow_dispatch only
* no PR trigger

Fix:

* enable GitHub Actions
* manually run workflow

---

## 2. Terraform fmt Failed

Fix:

```bash
terraform fmt -recursive
```

Then:

```bash
git add .
git commit -m "Fix formatting"
git push
```

---

## 3. S3 Bucket Not Empty

Reason:

* versioning enabled
* old versions still exist

Need to delete:

* object versions
* delete markers

---

## 4. Wrong PR Repository

Wrong:

```text
Feature branch → Original repo
```

Correct:

```text
Feature branch → Your fork main
```

Fix:

* close incorrect PR
* create PR again from your fork

---

# Useful Git Commands

## Check branch

```bash
git branch
```

---

## Create branch

```bash
git checkout -b feature/my-branch
```

---

## Push branch

```bash
git push origin feature/my-branch
```

---

## Check remotes

```bash
git remote -v
```

---

## Change remote

```bash
git remote set-url origin https://github.com/Balasai234/zen-infra.git
```

---

# Useful Terraform Commands

## Initialize

```bash
terraform init
```

---

## Validate

```bash
terraform validate
```

---

## Format

```bash
terraform fmt -recursive
```

---

## Plan

```bash
terraform plan
```

---

## Apply

```bash
terraform apply
```

---

## Destroy

```bash
terraform destroy
```

---

# Recommended Real-World Workflow

## Developer Flow

```text
1. Create feature branch
2. Make changes
3. Push branch
4. Create PR
5. Terraform Plan
6. Review plan
7. Merge PR
8. Trigger Apply manually
9. Approve deployment
10. Verify infrastructure
```

---

# Verification After Apply

## Check Kubernetes Nodes

```bash
kubectl get nodes
```

---

## Check All Pods

```bash
kubectl get pods -A
```

---

## Verify AWS Resources

Check in AWS Console:

* EKS
* EC2
* RDS
* VPC
* NAT Gateway
* ECR
* IAM

---

# Cost Reminder

Running resources continuously costs money.

Most expensive components:

* NAT Gateway
* EKS Control Plane
* RDS

Destroy infrastructure when not practicing.

---

# Final Learning Summary

This project demonstrates:

* GitOps workflow
* PR-based infrastructure deployment
* Terraform remote backend
* GitHub Actions CI/CD
* AWS infrastructure automation
* Manual approval workflow
* Environment-based deployments
* Infrastructure lifecycle management

This is very close to real enterprise DevOps practices.

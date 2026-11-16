# minidis-platform

Infrastructure for running [minidis](https://github.com/ShearlingEnMouton/minidis) on Google Kubernetes Engine (GKE) Autopilot. The cloud resources are defined with Terraform, and the workloads are deployed with Argo CD from this repository (GitOps).

This repository is a work in progress. Only the bootstrap step exists so far.

## Layout

| Path | Content |
| --- | --- |
| `terraform/bootstrap` | The Cloud Storage bucket that stores the Terraform state of the other configurations |
| `terraform/gke` | The network, the GKE Autopilot cluster and the Argo CD installation (planned) |
| `argocd` | Argo CD applications for minidis and monitoring (planned) |

## Requirements

- Terraform 1.17 or later
- The Google Cloud CLI (`gcloud`), signed in with an account that can create resources in the target project:

  ```sh
  gcloud auth login
  gcloud auth application-default login
  gcloud auth application-default set-quota-project <project-id>
  ```

  Terraform reads the Application Default Credentials (ADC) created by the second command. No service account key is stored in this repository.

## Bootstrap

The other configurations store their state in a Cloud Storage bucket, so the bucket has to exist first. `terraform/bootstrap` creates it and keeps its own state locally, because the bucket it would use does not exist yet.

```sh
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars   # set project_id
terraform init
terraform plan
terraform apply
```

The bucket is named `<project-id>-tfstate` and is created in `europe-west9` by default. Object versioning is enabled, so an earlier version of a state file can be restored after a bad write. Access is controlled through IAM only (uniform bucket-level access), and public access is blocked.

`terraform output state_bucket` prints the bucket name.

The local state file `terraform/bootstrap/terraform.tfstate` is not committed. It is needed only to change or delete the bucket later. If it is lost, the bucket can be brought back under Terraform with `terraform import`.

| Variable | Default | Description |
| --- | --- | --- |
| `project_id` | none | Google Cloud project that holds the bucket |
| `region` | `europe-west9` | Location of the bucket |

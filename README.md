# minidis-platform

Infrastructure for running [minidis](https://github.com/ShearlingEnMouton/minidis) on Google Kubernetes Engine (GKE) Autopilot. The cloud resources are defined with Terraform, and the workloads are deployed with Argo CD from this repository (GitOps).

This repository is a work in progress. The state bucket, the GKE cluster and the Argo CD installation exist so far; the Argo CD applications for minidis and monitoring are planned.

## Layout

| Path | Content |
| --- | --- |
| `terraform/bootstrap` | The Cloud Storage bucket that stores the Terraform state of the other configurations |
| `terraform/gke` | The VPC network and subnet, and the GKE Autopilot cluster |
| `terraform/argocd` | The Argo CD installation on the cluster, from the official Helm chart |
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

## GKE cluster

`terraform/gke` creates:

- The Kubernetes Engine and Compute Engine APIs in the project. Destroying the configuration leaves them enabled, because other tools in the project may rely on them.
- A custom-mode VPC network named after the cluster, without automatically created subnets.
- One subnet in the cluster region. Its primary range holds the node addresses, and two secondary ranges hold the Pod and Service addresses, as required by VPC-native clusters. GKE Autopilot clusters are always VPC-native.
- A regional GKE Autopilot cluster on the default release channel. Google manages the nodes: they are created when Pods are scheduled, so a new cluster has no nodes.

The state is stored in the bootstrap bucket under the `gke` prefix. Run the bootstrap step first, and update the `bucket` value of the `backend "gcs"` block in `versions.tf` if the project ID is different. A backend block cannot use variables.

```sh
cd terraform/gke
cp terraform.tfvars.example terraform.tfvars   # set project_id
terraform init
terraform plan
terraform apply
```

Creating the cluster takes about ten minutes. Deletion protection is turned off on the cluster, so `terraform destroy` removes it. Review the plan before applying any change that replaces the cluster.

To connect `kubectl`, run the command printed by `terraform output -raw get_credentials_command`. It adds the cluster to the kubeconfig file and makes it the current context.

| Variable | Default | Description |
| --- | --- | --- |
| `project_id` | none | Google Cloud project that holds the network and the cluster |
| `region` | `europe-west9` | Region of the subnet and the cluster |
| `cluster_name` | `minidis` | Name of the cluster. Also used for the network and the secondary range names |
| `subnet_node` | `10.10.0.0/20` | Primary range of the subnet, for node addresses |
| `subnet_pod` | `10.20.0.0/16` | Secondary range for Pod addresses |
| `subnet_service` | `10.30.0.0/20` | Secondary range for Service ClusterIP addresses |

The three ranges must not overlap. They cannot be changed on an existing cluster without recreating it, so the Pod range is sized generously: GKE reserves a block of Pod addresses for each node, not for each Pod.

| Output | Description |
| --- | --- |
| `cluster_name` | Name of the cluster |
| `cluster_location` | Region of the cluster |
| `get_credentials_command` | `gcloud` command that adds the cluster to the local kubeconfig |

## Argo CD

`terraform/argocd` installs Argo CD into the `argocd` namespace with the `argo-cd` chart from the Argo project Helm repository. It is a separate configuration from `terraform/gke`: the Helm provider needs the address and credentials of a cluster that already exists, and configuring a provider from a resource created in the same configuration breaks when the cluster does not exist yet or is replaced.

The configuration reads the cluster created by `terraform/gke` with a `google_container_cluster` data source and gets a short-lived access token from `google_client_config`, so no kubeconfig file and no stored credential is involved. Its state is stored in the bootstrap bucket under the `argocd` prefix.

```sh
cd terraform/argocd
cp terraform.tfvars.example terraform.tfvars   # set project_id
terraform init
terraform plan
terraform apply
```

The chart version is pinned in `main.tf`. `values.yaml` holds only the values that differ from the chart defaults:

- The application controller, the repo server, the API server and Redis run with small resource requests. GKE Autopilot bills Pod requests and gives every container without requests 0.5 vCPU and 2 GiB of memory, so each component sets its own.
- Dex (single sign-on), the notifications controller and the ApplicationSet controller are turned off, because this setup does not use them.

The Argo CD server is reachable only inside the cluster (`ClusterIP`). To open the web UI:

```sh
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Then open `https://localhost:8080` and sign in as `admin`. `terraform output -raw argocd_admin_password_command` prints the command that reads the initial password. The password is not exposed as a Terraform output, so it is not written to the Terraform state.

| Variable | Default | Description |
| --- | --- | --- |
| `project_id` | none | Google Cloud project that holds the cluster |
| `region` | `europe-west9` | Region of the cluster |
| `cluster_name` | `minidis` | Name of the cluster created by `terraform/gke` |

## Continuous integration

The `terraform` workflow runs on every pull request and on every push to `main`. It needs no Google Cloud credentials:

- `terraform fmt -check -recursive` checks the formatting of every configuration.
- For each configuration, `terraform init -backend=false` installs the providers without reaching the state bucket, and `terraform validate` checks the syntax, the types and the references. Init runs with `-lockfile=readonly`, so the provider versions must match the committed `.terraform.lock.hcl`.

A new configuration directory must be added to the `config` matrix in `.github/workflows/terraform.yaml`. Running `terraform plan` in pull requests is planned, using Workload Identity Federation instead of a stored service account key.

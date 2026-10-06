
# Enterprise Azure Kubernetes Service (AKS) Infrastructure

This repository provisions a secure, production-ready Azure Kubernetes Service (AKS) cluster paired with an Azure Container Registry (ACR) and dedicated Virtual Network infrastructure using Terraform.

## Architecture Diagram

```text
 +-----------------------------------------------------------------------+
 | Resource Group: rg-andrei                                            |
 |                                                                       |
 |  +-----------------------+        +--------------------------------+  |
 |  | Virtual Network       |        | Azure Container Registry (ACR) |  |
 |  | (vnet-andrei)         |        | (crandreiaks2026)              |  |
 |  |  +-----------------+  |        +---------------+----------------+  |
 |  |  | Subnet: snet-aks|  |                        | (AcrPull)         |
 |  |  +--------+--------+  |                        v                   |
 |  +-----------|-----------+        +--------------------------------+  |
 |              |                    | User-Assigned Identity         |  |
 |              |                    | (id-aks-andrei)                |  |
 |              |                    +---------------+----------------+  |
 |              |                                    |                   |
 |              v                                    v                   |
 |  +-----------------------------------------------------------------+  |
 |  | Azure Kubernetes Service (aks-andrei)                            |  |
 |  |  * Azure CNI (Overlay Network)                                  |  |
 |  |  * OIDC & Workload Identity Enabled                             |  |
 |  |  * System Node Pool (Auto-scaling: 1-3 nodes)                    |  |
 |  +-----------------------------------------------------------------+  |
 +-----------------------------------------------------------------------+
```

## Features

* **Network Isolation:** Provisioned in a dedicated VNet (`10.0.0.0/16`) using **Azure CNI** with non-overlapping Service CIDR (`10.2.0.0/16`).
* **Zero-Trust Identity:** Utilizes User-Assigned Managed Identity for cluster operations, eliminating hardcoded service principal credentials.
* **Passwordless Registry Access:** Native `AcrPull` IAM binding between AKS and Azure Container Registry.
* **Modern Auth Platform:** OIDC Issuer and Workload Identity pre-configured for pod-level Azure authentication.

## Prerequisites

Before running Terraform, ensure you have installed:

* [Terraform](https://www.terraform.io/downloads) (>= 1.3.0)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (>= 2.50.0)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)

An existing Azure Resource Group named **`rg-andrei`** must be created prior to execution.

## File Structure

```text
.
├── main.tf        # Data sources (Existing Resource Group reference)
├── network.tf     # Virtual Network and Subnet definitions
├── identity.tf    # Managed Identity & Subnet RBAC assignments
├── acr.tf         # Azure Container Registry & AcrPull RBAC
├── aks.tf         # AKS Cluster configuration
├── providers.tf   # Provider constraints
├── variables.tf   # Variable defaults
├── outputs.tf     # Cluster metadata & connection strings
└── README.md
```

## Quickstart Deployment

### 1. Authenticate to Azure

```bash
az login
az account set --subscription "<your-subscription-id>"
```

### 2. Initialize & Deploy Terraform

```bash
# Initialize providers and modules
terraform init

# Review proposed changes
terraform plan

# Deploy infrastructure
terraform apply -auto-approve
```

### 3. Connect to the AKS Cluster

Fetch the cluster credentials and populate your local `~/.kube/config`:

```bash
az aks get-credentials --resource-group rg-andrei --name aks-andrei

# Verify node status
kubectl get nodes -o wide
```

### 4. Authenticate to Azure Container Registry

```bash
az acr login --name crandreiaks2026
```

## Input Variables

| Name                    | Description                                | Type       | Default             | Required |
| :---------------------- | :----------------------------------------- | :--------- | :------------------ | :------: |
| `resource_group_name` | Name of the target existing Resource Group | `string` | `rg-andrei`       |    no    |
| `location`            | Azure region for resources                 | `string` | `westeurope`      |    no    |
| `cluster_name`        | Name of the AKS cluster                    | `string` | `aks-andrei`      |    no    |
| `acr_name`            | Name of the ACR (must be globally unique)  | `string` | `crandreiaks2026` |    no    |

## Outputs

| Name                    | Description                                     |
| :---------------------- | :---------------------------------------------- |
| `aks_cluster_name`    | The provisioned AKS cluster name                |
| `acr_login_server`    | The login URL for pushing images to ACR         |
| `connect_cluster_cmd` | The Azure CLI command to retrieve`kubeconfig` |

## Teardown

To destroy all managed infrastructure (excluding the pre-existing Resource Group):

```bash
terraform destroy -auto-approve
```

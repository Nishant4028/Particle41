
# 🚀 Azure AKS Private Cluster & Application Deployment

Welcome to the **Particle41 DevOps Project**. This repository contains the complete source code and Infrastructure-as-Code (IaC) required to provision a secure, private Azure Kubernetes Service (AKS) cluster and deploy a containerized Python application.

## 📋 Table of Contents
1. [Prerequisites](#-prerequisites)
2. [Repository Structure](#-repository-structure)
3. [Security & Configuration](#-security--configuration)
4. [Deployment Guide](#-deployment-guide)
    - [Part 1: Provisioning Infrastructure](#part-1-provisioning-infrastructure)
    - [Part 2: Deploying the Application](#part-2-deploying-the-application)
5. [Infrastructure Architecture](#-infrastructure-architecture)
6. [Troubleshooting](#-troubleshooting)

---

## 🛠 Prerequisites

Before you begin, ensure you have the following tools installed on your local machine:

| Tool | Purpose | Installation Link |
| :--- | :--- | :--- |
| **Azure CLI** | To interact with Azure resources and authenticate. | [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| **Terraform** | To run IaC validation or planning locally. | [Install Terraform](https://developer.hashicorp.com/terraform/install) |
| **Docker** | To build and test container images locally. | [Install Docker Desktop](https://www.docker.com/products/docker-desktop/) |
| **kubectl** | To interact with the Kubernetes cluster. | [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) |
| **Git** | To clone this repository. | [Install Git](https://git-scm.com/downloads) |

---

## 📂 Repository Structure

The project is organized to separate infrastructure code from application code:

* **`API-source-code/`**: Contains the Python application logic, `Dockerfile`, and `requirements.txt`.
* **`Terraform_AKS_manifest/`**: Root directory for Terraform.
    * **`modules/`**: Reusable modules for `network`, `aks`, and `appgw`.
    * `main.tf`, `variables.tf`, `terraform.tfvars`: Entry points for dynamic infrastructure configuration.
* **`k8s manifest-file/`**: Kubernetes YAML files for the application deployment (`deployment`, `service`, `ingress`).
* **`azure-pipelines.yml`**: CI Pipeline for building and pushing Docker images.
* **`Infra-pipeline.yml`**: Pipeline for provisioning Azure infrastructure.

---

## 🔐 Security & Configuration

This project relies on **Azure DevOps Service Connections** to handle authentication securely, ensuring sensitive credentials are **never** hardcoded in the `YAML` files.

### 1. Setup Azure Service Connection (For IaC)
Required for `Infra-pipeline.yml` to provision resources in Azure.
* **Connection Name:** `devops-to-azure`
* **Configuration:** Azure DevOps > Project Settings > Service Connections. Create a connection of type **Azure Resource Manager** (Service Principal automatic).

### 2. Setup Docker Hub Service Connection (For CI)
Required for `azure-pipelines.yml` to push images to the registry.
* **Connection Name:** `devops-to-docker-hub`
* **Configuration:** Azure DevOps > Project Settings > Service Connections. Create a connection of type **Docker Registry**, providing your Docker Hub ID and Password.

---

## ⚙️ Deployment Guide

### Part 1: Provisioning Infrastructure
The infrastructure is provisioned using the **`Infra-pipeline.yml`** which utilizes Terraform and a remote Azure Storage Backend for state management.

1.  **Backend Setup:** Ensure the Azure Storage Account (`nishant12311`), Resource Group (`azuredevops-rg`), and Container (`tfstatefiles`) specified in the pipeline exist.
2.  **Run Pipeline:** Trigger the `Infra-pipeline.yml` in Azure DevOps.
3.  **Pipeline Stages:**
    * **TerraformValidate:** Installs Terraform, validates syntax, and publishes the `Terraform_AKS_manifest` as an artifact.
    * **DeployAKSClusters:** Initializes Terraform with the remote state, runs `terraform plan`, and executes `terraform apply` to create the VNet, Subnets, AKS, and Application Gateway.

### Part 2: Deploying the Application

**Step A: Build & Push Image (CI)**
1.  Trigger the **`azure-pipelines.yml`** pipeline.
2.  This pipeline builds the Docker image from `API-source-code/` and securely pushes it to your Docker Hub repository.

**Step B: Deploy to Kubernetes (CD)**
1.  **Connect to Cluster:** Since the AKS cluster is **private**, you must access it via the **Jumpbox** subnet 
    ```bash
    az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
    ```
2.  **Update Manifests:** Ensure `k8s manifest-file/deployment.yml` references the correct, latest Docker Hub image tag (e.g., `nishant4028/SimpleTimeService:latest`).
3.  **Apply Configuration:**
    ```bash
    kubectl apply -f "k8s manifest-file/deployment.yml"
    kubectl apply -f "k8s manifest-file/services.yml"
    kubectl apply -f "k8s manifest-file/ingress.yml"
    ```
*The **Ingress** file utilizes the **AGIC** addon to automatically configure routing on the Application Gateway.*


## 🔧 Troubleshooting

### Issue: AGIC Pod CrashLoopBackOff

**Symptom:**
The Application Gateway Ingress Controller (AGIC) pod is in a continuous `CrashLoopBackOff` state.

**Verification:**
Check the logs for authorization errors:
```bash
kubectl logs -n kube-system deploy/ingress-appgw-deployment
```
**Root Cause:**
The Managed Identity used by the AGIC pod lacks the necessary Azure RBAC permissions (**Contributor**, **Reader**, **Network Contributor**) to manage the Application Gateway and Network resources in the Azure subscription.

**Solution:**
Grant the required roles to the AGIC Managed Identity (you must retrieve the identity's Object ID or Client ID from Azure).

1.  **Grant Contributor on the Application Gateway:**
    *Required for AGIC to update the Gateway rules.*
    ```bash
    az role assignment create \
      --assignee <AGIC_IDENTITY_OBJECT_ID> \
      --role Contributor \
      --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP_NAME>/providers/Microsoft.Network/applicationGateways/<APPGW_NAME>
    ```

2.  **Grant Reader on the Resource Group:**
    *Required for AGIC to read resource properties.*
    ```bash
    az role assignment create \
      --assignee <AGIC_IDENTITY_OBJECT_ID> \
      --role Reader \
      --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP_NAME>
    ```

3.  **Grant Network Contributor on the VNet:**
    *Required if AGIC needs to manage network resources within the VNet.*
    ```bash
    az role assignment create \
      --assignee <AGIC_IDENTITY_OBJECT_ID> \
      --role "Network Contributor" \
      --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP_NAME>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME>
    ```

**Final Step:** Delete the crashing pod to force a successful recreation:
```bash
kubectl delete pod -n kube-system -l app=ingress-appgw
```
----------------------------------------------------------------------------------------------------------------------------------

# 🏗️ Infrastructure Architecture

This document outlines the architectural decisions behind the **Particle41** infrastructure. The design prioritizes security, scalability, and industry-standard segregation of duties.

## 1. Modular Terraform Design
We utilize a modular directory structure to make the infrastructure reusable and easier to maintain.

| Module | Description |
| :--- | :--- |
| **`modules/network`** | Creates the Virtual Network (VNet) and divides it into 4 distinct subnets (see below). |
| **`modules/appgw`** | Provisions the Application Gateway and Public IP. It handles WAF (Web Application Firewall) and Layer 7 load balancing. |
| **`modules/aks`** | Provisions the Private AKS Cluster and attaches it to the Application Gateway. |

## 2. Network Segmentation & Security
Security is handled through strict network segmentation. The VNet is divided into **4 Subnets**:

### A. Public Subnets
1.  **Application Gateway Subnet:** Dedicated solely to the App Gateway. This is the *only* entry point for HTTP traffic from the internet.
2.  **Jumpbox (Bastion) Subnet:** Since the AKS cluster is private, its API server cannot be accessed over the public internet. We place a "Jumpbox" VM here to allow administrators to securely SSH in and run `kubectl` commands for troubleshooting.

### B. Private Subnets
1.  **System Node Pool:** Hosted in a private subnet. These nodes run critical cluster services (CoreDNS, Metrics Server, etc.).
2.  **User Node Pool:** Hosted in a separate private subnet. This is where your actual application containers (Pods) are deployed.

## 3. Ingress Strategy (AGIC)
Instead of using a standard in-cluster Ingress Controller (like Nginx), we use the **Application Gateway Ingress Controller (AGIC)**.

* **How it works:** When we deploy `ingress.yml` to the cluster, AGIC translates these rules and automatically updates the Azure Application Gateway.
* **Benefits:**
    * **Performance:** Traffic goes directly to the pods without extra hops.
    * **Security:** Utilizing Azure's native WAF capabilities on the Gateway.
    * **Isolation:** The Gateway lives outside the cluster, reducing resource load on the nodes.

## 4. Pipeline Security
We strictly adhere to the principle of **Secretless Manifests**.
* **Service Connections:** We use Azure DevOps Service Connections for both Azure and Docker Hub.
* **Benefits:** We never store passwords, Client Secrets, or Subscription IDs in our `YAML` code. The pipeline authenticates via tokens managed by Azure DevOps.

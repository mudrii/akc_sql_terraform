# Microsoft Azure AKC and SQL Database with terraform

Tutorial structure:

* Initial tooling setup of azure CLI, kubectl, and Terraform
* Configure azure CLI
* Setup prerequisites for terraform account
  * Create Service Principals terraform account
  * Create resource group
  * Create storage account for terraform
  * Create Azure Blob Storage for Remote Terraform State tfstate
  * Configure terraform credentials to allow access Azure terraform service principal
* Review code structure
* Creating Kubernetes cluster on Azure AKC and PostgreSQL
* Working with kubernetes "kubectl" in AKC
* Destroy created infrastructure

1st we need to get all tools needed azure cli, kubectl and terraform

## Initial tooling setup of azure CLI, kubectl, and Terraform

### Deploying azure cli

At the time of this article we are using latest available cli version 2.0.45.
We have few option to install or run azure cli. [Official Azure CLI 2.0 documentation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

#### az cli for OS X

For OC X az cli we will use [homebrew](https://docs.brew.sh/Installation.html)

```sh
brew update

brew install azure-cli

# If unable to find Python run below command in the shell that should fix the issue
brew link --overwrite python3
```

#### az cli for Linux

As cli installation is very much dependant on Linux Distribution we gave installation script that should work on all Linux boxes

```sh
curl -L https://aka.ms/InstallAzureCli | bash

# or with full link
curl https://azurecliprod.blob.core.windows.net/install | bash
```

#### az cli in docker

```sh
docker run -it microsoft/azure-cli

# you can use SSH keys from your user environment
docker run -it -v ${HOME}/.ssh:/root/.ssh microsoft/azure-cli

#or you can use alias with azure sdk docker image
alias az='docker run -v ${HOME}:/root -it --rm azuresdk/azure-cli-python az'   
```

#### Installation verification

```sh
az --version

azure-cli (2.0.45)

acr (2.1.4)
acs (2.3.2)
advisor (0.6.0)
ams (0.2.3)
appservice (0.2.3)
backup (1.2.1)
batch (3.3.3)
batchai (0.4.2)
billing (0.2.0)
botservice (0.1.0)
cdn (0.1.1)
cloud (2.1.0)
cognitiveservices (0.2.1)
command-modules-nspkg (2.0.2)
configure (2.0.18)
consumption (0.4.0)
container (0.3.3)
core (2.0.45)
cosmosdb (0.2.1)
dla (0.2.2)
dls (0.1.1)
dms (0.1.0)
eventgrid (0.2.0)
eventhubs (0.2.3)
extension (0.2.1)
feedback (2.1.4)
find (0.2.12)
interactive (0.3.28)
iot (0.3.1)
iot (0.3.1)
iotcentral (0.1.1)
keyvault (2.2.2)
lab (0.1.1)
maps (0.3.2)
monitor (0.2.3)
network (2.2.4)
nspkg (3.0.3)
policyinsights (0.1.0)
profile (2.1.1)
rdbms (0.3.1)
redis (0.3.2)
relay (0.1.1)
reservations (0.3.2)
resource (2.1.3)
role (2.1.4)
search (0.1.1)
servicebus (0.2.2)
servicefabric (0.1.2)
sql (2.1.3)
storage (2.2.1)
telemetry (1.0.0)
vm (2.2.2)

Python location '/usr/local/bin/python'
Extensions directory '/root/.azure/cliextensions'

Python (Linux) 3.6.4 (default, Jan 10 2018, 05:20:21)
[GCC 6.4.0]

Legal docs and information: aka.ms/AzureCliLegal
```

### Deploying terraform

We will install latest terraform 0.11.8

#### terraform for OS X

```sh
curl -o terraform_0.11.8_darwin_amd64.zip \
https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.8_darwin_amd64.zip

unzip terraform_0.11.8_linux_amd64.zip -d /usr/local/bin/
```

#### terraform for Linux

```sh
curl https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip \
> terraform_0.11.8_linux_amd64.zip

unzip terraform_0.11.8_linux_amd64.zip -d /usr/local/bin/
```

#### terraform for Verification

Verify terraform version 0.11.8 or higher is installed:

```sh
terraform version

Terraform v0.11.8
```

### Deploying kubectl

#### kubectl for OS X

We will pull latest kubectl version to date 1.11.2

```sh
curl -o kubectl \
https://storage.googleapis.com/kubernetes-release/release/v1.11.2/bin/darwin/amd64/kubectl

chmod +x kubectl

sudo mv kubectl /usr/local/bin/
```

#### kubectl for Linux

```sh
wget \
https://storage.googleapis.com/kubernetes-release/release/v1.11.2/bin/linux/amd64/kubectl

chmod +x kubectl

sudo mv kubectl /usr/local/bin/
```

#### kubectl Verification

```sh
kubectl version --client

Client Version: version.Info{Major:"1", Minor:"10", GitVersion:"v1.10.3", GitCommit:"2bba0127d85d5a46ab4b778548be28623b32d0b0", GitTreeState:"clean", BuildDate:"2018-07-26T20:40:11Z", GoVersion:"go1.9.3", Compiler:"gc", Platform:"linux/amd64"}
```

## Configure azure CLI

Once we have azure cli installed will need to configure to allow cli to access Azure Cloud Services

Associate Azure CLI with your Microsoft Azure cloud account:

```sh
az login
```

You are then be prompted to open a web browser at a specific URL (seen in the response to your login command). Open a browser from any computer to that URL and enter the code you see specified. This associates your CLI instance with your Azure Cloud Account and completes the login process.

You can login using additional options following [link](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-login)

You may want to do additional configurations; example adding color, json output etc.

```sh
az configure
```

List accounts associated with CLI:

```sh
az account list
```

For more information you can follow [Azure CLI Official documentation](https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration?view=azure-cli-latest)

## Setup prerequisites for terraform account

In order to configure terraform we will need id's from azure account like tenantId, subscriptionId amd for newly created technical account terraform clientId.

Get a list of subscription ID and tenant ID values

```sh
az account show --query "{subscriptionId:id, tenantId:tenantId}"
```

### Create an Azure service principal

Service principals are separate identities that can be associated with an account. Service principals are useful for working with applications and tasks that can be automated.

```sh
export AZ_SUBSCRIPTION_ID=$(az account show --query id --out tsv)

az ad sp create-for-rbac --name terraform --role="Contributor" --scopes="/subscriptions/$AZ_SUBSCRIPTION_ID"
```

> Note Please note down output from "password" field

Once service principal account was created we will need to export the rest of required environment variables

```sh
export AZ_CLIENT_ID=$(az ad sp list --query "[?appDisplayName == 'terraform']|[].appId" --out tsv) && \
export AZ_TENANT_ID=$(az ad sp list --display-name terraform --query "[].appOwnerTenantId" --out tsv) && \
export AZ_CLIENT_NAME_ID=$(az ad sp list --query "[?appDisplayName == 'terraform']|[].appId" --out tsv) && \
export AZ_CLIENT_SECRET="PASSWORD-XXXX-XXXX-XXXX-PASSWORD"

printenv | grep AZ
```

> NOTE: for AZ_CLIENT_SECRET replace "PASSWORD-XXXX-XXXX-XXXX-PASSWORD" with output from field "password" when running  az ad sp create-for-rbac  ..... 

Verified by listing the assigned roles

```sh
az role assignment list --assignee $AZ_CLIENT_ID
```

Show details on service principal account

```sh
az ad sp show --id $AZ_CLIENT_NAME_ID
```

Optional you can test account by sign in using the service principal

```sh
az login --service-principal --username $AZ_CLIENT_NAME_ID --password $AZ_CLIENT_SECRET --tenant $AZ_TENANT_ID
```

Sign in in back with your Azure user account

```sh
az login -u your@email -p your_password
```

> NOTE: replace your@email and your password with your login credentials to Azure

Optional: If you need you can reset password

```sh
az ad sp credential reset --name $AZ_CLIENT_NAME_ID --password NEW_PASSWORD
```

### Create resource group

Before deploying any resources to your subscription, you must create a resource group that will contain the resources. Newly created resource group will be used for terraform service principal account to host azure blop storage for tsftate files.

List available locations where can will create resource group

```sh
az account list-locations --query []."{displayName:displayName, name:name}" --out table
```

Create resource group

" in below example we will use Southeast Asia region

```sh
az group create --name Terraform --location "Southeast Asia"
```

If you need to retrieve the resource group later, use the following command:

```sh
az group show --name Terraform
```

To get all the resource groups in your subscription, use:

```sh
az group list
```

### Create storage account for tfstate file

```sh
az storage account create -n terraformeks -g Terraform -l southeastasia --sku Standard_LRS
```

Retrieve storage account resource information by following command

```sh
az storage account show --name terraformeks --resource-group Terraform
```

Assign tags to the storage account resource

```sh
az resource tag --tags Environment=Test Resource=tfstate -g Terraform -n terraformeks --resource-type "Microsoft.Storage/storageAccounts"
```

#### Create a container in your Azure storage account

In order to create new storage container we will need to find account key

```sh
az storage account keys list -g Terraform -n terraformeks --query [0].value -o tsv
```

Export account key into env variable

```sh
ACCOUNT_KEY="$(az storage account keys list -g Terraform -n terraformeks --query [0].value -o tsv)"
```

Create container for terraform tfstate files

```sh
az storage container create -n tfstate --account-name terraformeks --account-key $ACCOUNT_KEY
```

Verify container creation

```sh
az storage container list --account-name terraformeks
```

### Optional: Retrieve information on newly created

Get resource by name

```sh
az resource list -n terraformeks
```

Get all the resources in a resource group

```sh
az resource list --resource-group Terraform
```

Resources with a particular resource type

```sh
az resource list --resource-type "Microsoft.Storage/storageAccounts"
```

Get all the resources with a tag name and value

```sh
az resource list --tag Environment=Test
```

#### Configure terraform credentials to allow access Azure terraform service principal

We will create 2 tfvars file and populate with credentials.

backend.tfvars will be used to create tfstate file in terraformeks azure container
terraform.tfvars will be used to provision azure infrastructure

Create and populate terraform.tfvars file

```sh
subscription_id = "$AZ_SUBSCRIPTION_ID"
client_id       = "$AZ_CLIENT_NAME_ID"
client_secret   = "$AZ_CLIENT_SECRET"
tenant_id       = "$AZ_TENANT_ID"
pgsql_password   = "$YOUR_DB_PASSWORD"
```

Create and populate backend.tfvars file

```sh
resource_group_name   = "Terraform"
storage_account_name  = "terraformeks"
container_name        = "tfstate"
access_key            = "$ACCOUNT_KEY"
key                   = "terraform.tfstate"
```

> NOTE: Replace $AZ_SUBSCRIPTION_ID, $AZ_CLIENT_NAME_ID, $AZ_CLIENT_SECRET, $AZ_TENANT_ID and $ACCOUNT_KEY with data from environment variables exported earlier "printenv | grep AZ"

## Review code structure

As in previous article for Gcloud and AWS we will make use of workspace and modules that give us better terraform code management

Code structure

```sh
.
├── aks_cluster
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── az_psql
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── backend.tf
├── backend.tfvars
├── base
│   ├── sec_group
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── subnet
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── main.tf
├── outputs.tf
├── README.md
├── resource_group
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── terraform.tfvars
├── variables.tf
```

1st we will need to setup our backend

```sh
terraform {
  backend "azurerm" {}
}
```

Initiate terraform plugin download

```sh
terraform init -backend-config=backend.tfvars
```

Add terraform workspace

```sh
terraform workspace new dev
```

Check terraform workspace

```sh
terraform workspace list
```

Check out main.tf file that will pull modules from diff folders.

```sh
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

module "res_group" {
  source   = "./resource_group"
  location = "${var.location}"
}

module "vpc" {
  source         = "./base/vpc"
  address_space  = "${var.address_space}"
  location       = "${var.location}"
  res_group_name = "${module.res_group.res_group_name}"
}

module "sec_group" {
  source         = "./base/sec_group"
  location       = "${var.location}"
  res_group_name = "${module.res_group.res_group_name}"
}

module "subnet" {
  source           = "./base/subnet"
  res_group_name   = "${module.res_group.res_group_name}"
  net_sec_group_id = "${module.sec_group.net_sec_group_id}"
  vnet_name        = "${module.vpc.vnet_name}"
  subnet_prefixes  = "${var.subnet_prefixes}"
}

module "eks_cluster" {
  source         = "./aks_cluster"
  res_group_name = "${module.res_group.res_group_name}"
  subnet_id      = "${module.subnet.subnet_id}"
  location       = "${var.location}"
  ssh_public_key = "${var.ssh_public_key}"
  agent_count    = "${var.agent_count}"
  client_id      = "${var.client_id}"
  client_secret  = "${var.client_secret}"
}

module "az_psql" {
  source                 = "./az_psql"
  location               = "${var.location}"
  res_group_name         = "${module.res_group.res_group_name}"
  pgsql_capacity         = "${var.pgsql_capacity}"
  pgsql_tier             = "${var.pgsql_tier}"
  pgsql_storage          = "${var.pgsql_storage}"
  pgsql_backup           = "${var.pgsql_backup}"
  pgsql_redundant_backup = "${var.pgsql_redundant_backup}"
  pgsql_password         = "${var.pgsql_password}"
}
```

After providing azure cridentials we will create resource group where our K8s cluster will reside

```sh
resource "azurerm_resource_group" "res_group" {
  name     = "aks-${terraform.workspace}"
  location = "${var.location}"

  tags {
    environment = "${terraform.workspace}"
  }
}
```

> NOTE: depending of the workspace you are in resource name will be different for dev or prod

Next step will create new vpc.

```sh
resource "azurerm_virtual_network" "vpc" {
  name          = "vpc-${terraform.workspace}"
  address_space = ["${lookup(var.address_space, terraform.workspace)}"]

  location            = "${var.location}"
  resource_group_name = "${var.res_group_name}"

  tags {
    environment = "${terraform.workspace}"
  }
}
```

> NOTE: VPC name and CIDR is dependent on workspace

Once VPC is created we can create Subnet

```sh
resource "azurerm_subnet" "subnet" {
  name                      = "akc-${terraform.workspace}-subnet"
  resource_group_name       = "${var.res_group_name}"
  network_security_group_id = "${var.net_sec_group_id}"
  virtual_network_name      = "${var.vnet_name}"
  address_prefix            = "${var.subnet_prefixes[terraform.workspace]}"
}
```

> NOTE: subnet name and CIDR dependant on workspace used

And last part for networking we need to create security group

```sh
resource azurerm_network_security_group "net_sec_group" {
  name                = "akc-${terraform.workspace}-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.res_group_name}"

  tags {
    environment = "${terraform.workspace}"
  }
}
```

Now is time to deploy AKC cluster

```sh
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "k8s-${terraform.workspace}"
  location            = "${var.location}"
  resource_group_name = "${var.res_group_name}"
  dns_prefix          = "k8s-${terraform.workspace}"

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "${file("${var.ssh_public_key}")}"
    }
  }

  agent_pool_profile {
    name            = "agentpool"
    count           = "${var.agent_count[terraform.workspace]}"
    vm_size         = "Standard_DS2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id  = "${var.subnet_id}"
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  network_profile {
    network_plugin = "azure"
  }

  tags {
    Environment = "${terraform.workspace}"
  }
}
```

> NOTE: nr of nodes is dependent on workspace your are in

And last part we will deploy DB PostgreeSQL Azure service

```sh
resource "azurerm_postgresql_server" "az_psql" {
  name                = "az-${terraform.workspace}-psql"
  location            = "${var.location}"
  resource_group_name = "${var.res_group_name}"

  sku {
    name     = "B_Gen5_2"
    capacity = "${var.pgsql_capacity[terraform.workspace]}"
    tier     = "${var.pgsql_tier[terraform.workspace]}"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = "${var.pgsql_storage[terraform.workspace]}"
    backup_retention_days = "${var.pgsql_backup[terraform.workspace]}"
    geo_redundant_backup  = "${var.pgsql_redundant_backup[terraform.workspace]}"
  }

  administrator_login          = "psqladmin"
  administrator_login_password = "${var.pgsql_password}"
  version                      = "9.6"
  ssl_enforcement              = "Enabled"

  tags {
    Environment = "${terraform.workspace}"
  }
}
```

> NOTE: as in previous example capacity and type of node depends on workspace.

## Creating Kubernetes cluster on Azure AKC and PostgreSQL

Is time to deploy our infrastructure

View terraform plan

```sh
terraform plan
```

Deploy infrastructure with terraform

```sh
terraform apply
```

Alternative we can export our plan and apply exported plan

```sh
terraform plan -out=my.plan
terraform show my.plan
terraform apply my.plan
```

## Working with kubernetes "kubectl" in AKC

Connect to terraform

```sh
export KUBECONFIG=~/.kube/azurek8s
echo "$(terraform output ekc_kube_config)" > ~/.kube/azurek8s
```

Now we should be able to access kubernetes API with kubectl

```sh
kubectl get nodes
kubectl get namespaces
kubectl get services
```

## Destroy created infrastructure

### Destroy infrastructure created with terraform

```sh
terraform destroy -auto-approve
```

### Remove all resource created with az cli

#### Delete terraform service principal

```sh
az ad sp list --query "[?appDisplayName == 'terraform']|[].appId"
az ad sp delete --id $AZ_CLIENT_ID
```

#### Delete storage account

```sh
az storage account list
az storage account delete -y -n terraformeks -g Terraform
```

#### Delete a resource group and all its resources

```sh
az group list
az group delete -y -n Terraform
```

Terraform sources can be found in [GitHub](https://github.com/mudrii/akc_sql_terraform)
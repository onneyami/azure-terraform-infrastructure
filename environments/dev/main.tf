data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

module "network" {
  source = "../../modules/network"

  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  vnet_name                = "vnet-andrei-dev"
  vnet_address_space       = ["10.0.0.0/16"]
  subnet_name              = "snet-aks-dev"
  subnet_address_prefixes  = ["10.0.1.0/24"]
  tags                     = var.tags
}

module "acr" {
  source = "../../modules/acr"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  acr_name            = var.acr_name
  sku                 = "Standard"
  tags                = var.tags
}

module "aks" {
  source = "../../modules/aks"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  cluster_name        = var.cluster_name
  subnet_id           = module.network.subnet_id
  acr_id              = module.acr.acr_id

  vm_size        = "Standard_D2s_v5"
  node_count     = 2
  min_count      = 1
  max_count      = 3
  service_cidr   = "10.2.0.0/16"
  dns_service_ip = "10.2.0.10"
  tags           = var.tags
}
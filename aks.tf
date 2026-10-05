resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "${var.cluster_name}-dns"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  default_node_pool {
    name                = "system"
    node_count          = 2
    vm_size             = "Standard_D2s_v5"
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"

  # --- CIDR FIX ---
    service_cidr      = "10.2.0.0/16" # Shifted outside 10.0.0.0/16 VNet range
    dns_service_ip    = "10.2.0.10"  # Must be an available IP within service_cidr

  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  depends_on = [
    azurerm_role_assignment.aks_subnet_network_contributor
  ]

  tags = data.azurerm_resource_group.rg.tags
}
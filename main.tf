provider "azurerm" {
  features {}
  subscription_id = "4ea9bae1-2d84-40f4-9e8a-3993ba62fc90"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-labchatgpt"
  location = "East US"
}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-labchatgpt"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = "f696e951-2278-4658-b25f-044f05a431a3"
  sku_name                    = "standard"
  purge_protection_enabled    = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-labchatgpt"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "labchatgpt"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "aks_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = "f696e951-2278-4658-b25f-044f05a431a3"
  object_id    = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_container_registry" "acr" {
  name                = "acrchatgptlab"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_service_plan" "this" {
  name                         = local.asp
  resource_group_name          = data.azurerm_resource_group.this.name
  location                     = data.azurerm_resource_group.this.location
  os_type                      = var.os_type
  sku_name                     = var.hosting.sku_name
  app_service_environment_id   = azurerm_app_service_environment_v3.this.id
  maximum_elastic_worker_count = local.maximum_elastic_worker_count
  worker_count                 = var.hosting.zone_balancing_enabled ? ceil(var.hosting.worker_count / length(data.azurerm_location.this.zone_mappings)) * length(data.azurerm_location.this.zone_mappings) : var.hosting.worker_count
  per_site_scaling_enabled     = var.hosting.per_site_scaling_enabled
  zone_balancing_enabled       = var.hosting.zone_balancing_enabled
  tags                         = local.tags
}

resource "azurerm_user_assigned_identity" "this" {
  name                = local.uami
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
}

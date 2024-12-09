resource "azurerm_app_service_environment_v3" "this" {
  count                                  = var.type == "ase" ? 1 : 0
  name                                   = local.ase
  resource_group_name                    = data.azurerm_resource_group.this.name
  location                               = data.azurerm_resource_group.this.location
  subnet_id                              = var.hosting.ase.subnet_id
  allow_new_private_endpoint_connections = true
  dynamic "cluster_setting" {
    for_each = var.hosting.ase.cluster_settings
    content {
      name  = cluster_setting.value.name
      value = cluster_setting.value.value
    }
  }
  dedicated_host_count         = var.hosting.ase.dedicated_host_count
  remote_debugging_enabled     = var.hosting.ase.remote_debugging_enabled
  zone_redundant               = var.hosting.ase.zone_redundant
  internal_load_balancing_mode = var.hosting.ase.internal_load_balancing_mode
  tags                         = local.tags
}

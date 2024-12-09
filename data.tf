data "azurerm_resource_group" "this" {
  name = var.resource_group_name.primary
}

data "azurerm_location" "this" {
  location = data.azurerm_resource_group.this.location
}

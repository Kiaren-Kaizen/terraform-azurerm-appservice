output "web_server_farm_id" {
  description = "The ID of the web server farm"
  value       = azurerm_app_service_plan.web_server_farm.id
}

output "web_server_farm_name" {
  description = "The name of the web server farm"
  value       = azurerm_app_service_plan.web_server_farm.name
}

output "web_server_farm_location" {
  description = "The location of the web server farm"
  value       = azurerm_app_service_plan.web_server_farm.location
}

output "web_server_farm_resource_group" {
  description = "The resource group of the web server farm"
  value       = azurerm_app_service_plan.web_server_farm.resource_group_name
}
output "web_server_farm_sku" {
  description = "The SKU of the web server farm"
  value       = azurerm_app_service_plan.web_server_farm.sku
}

output "web_server_farm_kind" {
  description = "The kind of the web server farm"
  value       = azurerm_app_service_plan.web_server_farm.kind
}

output "web_server_farm_tags" {
  description = "The tags of the web server farm"
  value       = azurerm_app_service_plan.web_server_farm.tags
}

output "web_server_farm_max_number_of_workers" {
  description = "The maximum number of workers for the web server farm"
  value       = azurerm_app_service_plan.web_server_farm.maximum_number_of_workers
}

output "web_server_farm_reserved" {
  description = "Is the web server farm reserved"
  value       = azurerm_app_service_plan.web_server_farm.reserved
}

output "ase_id" {
  description = "The ID of the App Service Environment"
  value       = azurerm_app_service_environment_v3.this[0].id
}

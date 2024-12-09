module "config" {
  source  = "app.terraform.io/group1001/config/global"
  version = "1.0.0"
}

module "primary_region_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
  suffix = [
    "asp",
    lower(var.common.environment),
    module.primary_region.location_short
  ]
}
module "secondary_region_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
  suffix = [
    "asp",
    lower(var.common.environment),
    module.secondary_region.location_short
  ]
}

module "app_landing_zone_outputs" {
  source          = "app.terraform.io/group1001/app-landing-zone-outputs/azurerm"
  version         = "~> 1.3"
  app_name        = var.common.app_name
  app_environment = var.common.environment
}

module "primary_region" {
  source       = "claranet/regions/azurerm"
  version      = "7.1.1"
  azure_region = module.config.az_region.primary
}

module "secondary_region" {
  source       = "claranet/regions/azurerm"
  version      = "7.1.1"
  azure_region = module.config.az_region.secondary
}
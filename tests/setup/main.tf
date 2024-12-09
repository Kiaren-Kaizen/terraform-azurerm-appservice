terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

module "primary_region_naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix = [
    "asp",
    "dev",
    "use2"
  ]
}

resource "azurerm_resource_group" "example_resource_group" {
  name     = "${module.naming.resource_group_name}-${module.naming.location}"
  location = module.config.az_region.primary
}

resource "azurerm_virtual_network" "example_virtual_network" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example_resource_group.location
  name                = "example_virtual_network"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "example_subnet" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "example_subnet"
  resource_group_name  = azurerm_resource_group.example_resource_group.name
  virtual_network_name = azurerm_virtual_network.example_virtual_network.name

  delegation {
    name = "example-delegation"

    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

module "test" {
  source              = "../.."
  os_type             = "Linux"
  resource_group_name = "my-resource-group"
  type                = "ase" # Indicating you are targeting ASE

  hosting = {
    server_farm = {
      sku_name                     = "I1v2" # SKU compatible with ASE
      maximum_elastic_worker_count = 10
      worker_count                 = 5
      per_sit_scaling_enabled      = true
      zone_balancing_enabled       = false
    }
    ase = {
      subnet_id = azurerm_subnet.example_subnet.id
      cluster_setting = {
        setting1 = { name = "Key1", value = "Value1" }
        setting2 = { name = "Key2", value = "Value2" }
      }
      dedicated_host_count         = 3
      remote_debugging_enabled     = false
      zone_redundant               = true
      internal_load_balancing_mode = "Web"
    }
  }
  webapps = {
    "webapp1" = {
      name    = "webapp1-name"
      enabled = true
      site_config = {
        always_on           = true
        load_balancing_mode = "LeastRequests"
        default_documents   = ["index.html"]
      }
      app_settings = {
        "key" = "value"
      }
      connection_strings = {
        "db" = {
          name  = "db-connection"
          type  = "SQLAzure"
          value = "connection-string-here"
        }
      }
      auth_settings = {
        enabled = true
        active_directory = {
          client_id = "some-client-id"
        }
      }
    }
  }

}
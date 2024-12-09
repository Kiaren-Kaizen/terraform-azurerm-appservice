variable "os_type" {
  type        = string
  description = "The Operating System type of the App Service Plan. Valid values are Windows and Linux."
  validation {
    condition     = contains(["Windows", "Linux"], var.os_type)
    error_message = "Valid values for os_type are Windows and Linux."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which the App Service Plan should exist."
}

// A variable that i can later use to trigger either a server farm  or a App service environment v3 
variable "type" {
  type        = string
  description = "The type of the App Service Plan. Valid values are server_farm and ase."
  validation {
    condition     = contains(["server_farm", "ase"], var.type)
    error_message = "Valid values for type are server_farm and ase."
  }
}


variable "hosting" {
  type = object({
    sever_farm = object({
      sku_name                     = string
      maximum_elastic_worker_count = optional(number)
      worker_count                 = optional(number)
      per_sit_scaling_enabled      = optional(bool, false)
      zone_balancing_enabled       = optional(bool, true)
    })
    ase = optional(object({
      subnet_id = string
      cluster_setting = map(object({
        name  = string
        value = string
      }))
      dedicated_host_count         = optional(number, 2)
      remote_debugging_enabled     = optional(bool, false)
      zone_redundant               = optional(bool, false)
      internal_load_balancing_mode = optional(string)
    }))
  })
  description = <<DESCRIPTION
  A map of App Service Plan settings. The map must contain the following keys:
  - `sever_farm` - The App Service Plan settings for a server farm. The map must contain the following keys:
    - `sku_name` - The SKU name of the App Service Plan.
    - `maximum_elastic_worker_count` - (Optional) The maximum number of workers that can be allocated to this App Service Plan.
    - `worker_count` - (Optional) The number of workers to allocate to this App Service Plan.
    - `per_site_scaling_enabled` - (Optional) Should per-site scaling be enabled for the App Service Plan.
    - `zone_balancing_enabled` - (Optional) Should zone balancing be enabled for the App Service Plan.
  - `ase` - The App Service Plan settings for an App Service Environment V3. The map must contain the following keys:
    - `subnet_id` - The ID of the subnet to use for the App Service Environment V3.
    - `cluster_setting` - A map of cluster settings for the App Service Environment V3.
    - `dedicated_host_count` - (Optional) The number of dedicated hosts to use for the App Service Environment V3.
    - `remote_debugging_enabled` - (Optional) Should remote debugging be enabled for the App Service Environment V3.
    - `zone_redundant` - (Optional) Should the App Service Environment V3 be zone redundant.
    - `internal_load_balancing_mode` - (Optional) The internal load balancing mode for the App Service Environment V3.
  DESCRIPTION
  validation {
    condition = (
      contains(["Y1", "FC1", "EP1", "EP2", "EP3"], var.hosting.sku_name) &&
      (var.hosting.sku_name != "EP1" || var.hosting.maximum_elastic_worker_count != null)
    )
    error_message = "Valid values for sku_name are Y1, FC1, EP1, EP2, EP3. EP1 requires maximum_elastic_worker_count to be set."
  }
  validation {
    condition     = can(regex("B1|B2|B3|D1|F1|I1|I2|I3|I1v2|I2v2|I3v2|I4v2|I5v2|I6v2|P1v2|P2v2|P3v2|P0v3|P1v3|P2v3|P3v3|P1mv3|P2mv3|P3mv3|P4mv3|P5mv3|S1|S2|S3|SHARED|EP1|EP2|EP3|FC1|WS1|WS2|WS3|Y1", var.hosting.sku_name))
    error_message = "The SKU name must be B1, B2, B3, D1, F1, I1, I2, I3, I1v2, I2v2, I3v2, I4v2, I5v2, I6v2, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, P1mv3, P2mv3, P3mv3, P4mv3, P5mv3, S1, S2, S3, SHARED, EP1, EP2, EP3, FC1, WS1, WS2, WS3, and Y1."
  }
  validation {
    condition = (
      !(var.hosting.ase.dedicated_host_count != null && var.hosting.ase.zone_redundant)
    )
    error_message = "You can only set either dedicated_host_count or zone_redundant but not both."
  }
  validation {
    condition = (
      var.hosting.app_service_environment_id == null ||
      (contains(["I1", "I2", "I3", "I1v2", "I2v2", "I3v2"], var.hosting.sku_name) && var.hosting.app_service_environment_id != null)
    )
    error_message = "app_service_environment_id requires an Isolated SKU. Use one of I1, I2, I3 for azurerm_app_service_environment, or I1v2, I2v2, I3v2 for azurerm_app_service_environment_v3."
  }
}

variable "webapps" {
  type = map(object({
    name    = string
    enabled = optional(bool, true)
    site_config = object({
      always_on             = optional(bool, true)
      api_definition_url    = optional(string)
      api_management_api_id = optional(string)
      app_command_line      = optional(string)
      auto_heal_setting = optional(object({
        action = object({
          action_type = string
          custom_action = optional(object({
            path         = string
            query_string = string
            http_verb    = string
          }))
          min_process_execution_time = string
        })
        triggers = object({
          private_memory_kb = optional(number)
          requests = optional(object({
            count         = number
            time_interval = string
          }))
          slow_requests = optional(object({
            time_taken    = string
            path          = string
            count         = number
            time_interval = string
          }))
          status_codes = optional(list(object({
            status        = string
            sub_status    = optional(string)
            win32_status  = optional(string)
            count         = number
            time_interval = string
          })))
        })
      }))
      container_registry_use_managed_identity = optional(bool)
      cors = optional(object({
        allowed_origins     = list(string)
        support_credentials = optional(bool, false)
      }))
      default_documents                 = optional(list(string))
      ftps_state                        = optional(string, "Disabled")
      health_check_path                 = optional(string)
      health_check_eviction_time_in_min = optional(number)
      http2_enabled                     = optional(bool, false)
      ip_restriction = optional(list(object({
        ip_address = string
        action     = string
        priority   = number
        name       = optional(string)
      })))
      load_balancing_mode = optional(string, "LeastRequests")
      scm_ip_restriction = optional(list(object({
        ip_address = string
        action     = string
        priority   = number
        name       = optional(string)
      })))
      vnet_route_all_enabled = optional(bool, false)
      worker_count           = optional(number)
    })
    app_settings = optional(map(string))
    connection_strings = optional(map(object({
      name  = string
      type  = string
      value = string
    })))
    client_certificate_enabled               = optional(bool, false)
    ftp_publish_basic_authentication_enabled = optional(bool, true)
    https_only                               = optional(bool, true)
    auth_settings = object({
      enabled = bool
      active_directory = optional(object({
        client_id                  = string
        allowed_audiences          = optional(list(string))
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
      }))
    })
  }))

  description = <<DESCRIPTION
  A map of Web App settings. The map must contain the following
  keys:
  - `name` - The name of the Web App.
  - `enabled` - (Optional) Should the Web App be enabled.
  - `site_config` - The site configuration settings for the Web App. The map must contain the following keys:
    - `always_on` - (Optional) Should the Web App always be on.
    - `api_definition_url` - (Optional) The URL of the API definition.
    - `api_management_api_id` - (Optional) The API Management API ID.
    - `app_command_line` - (Optional) The command line to launch the application.
    - `auto_heal_setting` - (Optional) The auto-heal settings for the Web App. The map must contain the following keys:
      - `action` - The action settings for the auto-heal. The map must contain the following keys:
        - `action_type` - The type of action to take.
        - `custom_action` - (Optional) The custom action to take.
        - `min_process_execution_time` - The minimum process execution time.
      - `triggers` - The triggers for the auto-heal. The map must contain the following keys:
        - `private_memory_kb` - (Optional) The private memory in KB.
        - `requests` - (Optional) The requests trigger settings. The map must contain the following keys:
          - `count` - The number of requests.
          - `time_interval` - The time interval.
        - `slow_requests` - (Optional) The slow requests trigger settings. The map must contain the following keys:
          - `time_taken` - The time taken.
          - `path` - The path.
          - `count` - The number of requests.
          - `time_interval` - The time interval.
        - `status_codes` - (Optional) The status codes trigger settings. The map must contain the following keys:
          - `status` - The status code.
          - `sub_status` - (Optional) The sub status code.
          - `win32_status` - (Optional) The Win32 status code.
          - `count` - The number of requests.
          - `time_interval` - The time interval.
    - `container_registry_use_managed_identity` - (Optional) Should the container registry use a managed identity.
    - `cors` - (Optional) The CORS settings for the Web App. The map must contain the following keys:
      - `allowed_origins` - The allowed origins.
      - `support_credentials` - (Optional) Should credentials be supported.
    - `default_documents` - (Optional) The default documents.
    - `ftps_state` - (Optional) The FTPS state.
    - `health_check_path` - (Optional) The health check path.
    - `health_check_eviction_time_in_min` - (Optional) The health check eviction time in minutes.
    - `http2_enabled` - (Optional) Should HTTP2 be enabled.
    - `ip_restriction` - (Optional) The IP restriction settings. The map must contain the following keys:
      - `ip_address` - The IP address.
      - `action` - The action.
      - `priority` - The priority.
      - `name` - (Optional) The name.
    - `load_balancing_mode` - (Optional) The load balancing mode.
    - `scm_ip_restriction` - (Optional) The SCM IP restriction settings. The map must contain the following keys
      - `ip_address` - The IP address.
      - `action` - The action.
      - `priority` - The priority.
      - `name` - (Optional) The name.
    - `vnet_route_all_enabled` - (Optional) Should VNET route all be enabled.
    - `worker_count` - (Optional) The worker count.
  - `app_settings` - (Optional) The application settings for the Web App.
  - `connection_strings` - (Optional) The connection strings for the Web App. The map must contain the following keys:
    - `name` - The name of the connection string.
    - `type` - The type of the connection string.
    - `value` - The value of the connection string.
  - `client_certificate_enabled` - (Optional) Should client certificates be enabled.
  - `ftp_publish_basic_authentication_enabled` - (Optional) Should FTP publish basic authentication be enabled.
  - `https_only` - (Optional) Should HTTPS only be enabled.
  - `auth_settings` - The authentication settings for the Web App. The map must contain the following keys:
    - `enabled` - Should authentication be enabled.
    - `active_directory` - The Active Directory settings for the Web App. The map must contain the following keys:
      - `client_id` - The client ID.
      - `allowed_audiences` - (Optional) The allowed audiences.
      - `client_secret` - (Optional) The client secret.
      - `client_secret_setting_name` - (Optional) The client secret setting name.
  DESCRIPTION
  # Validation for load_balancing_mode
  validation {
    condition = alltrue([
      for webapp in var.webapps : (
        webapp.site_config.load_balancing_mode == null ||
        contains([
          "WeightedRoundRobin", "LeastRequests", "LeastResponseTime",
          "WeightedTotalTraffic", "RequestHash", "PerSiteRoundRobin"
        ], webapp.site_config.load_balancing_mode)
      )
    ])
    error_message = "Valid values for load_balancing_mode are WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, and PerSiteRoundRobin."
  }
  # Validation for connection_strings.type
  validation {
    condition = alltrue([
      for webapp in var.webapps : (
        alltrue([
          for cs in(webapp.connection_strings != null ? values(webapp.connection_strings) : []) : (
            contains([
              "MySQL", "SQLServer", "SQLAzure", "Custom", "NotificationHub",
              "ServiceBus", "EventHub", "APIHub", "DocDb", "RedisCache", "PostgreSQL"
            ], cs.type)
          )
        ])
      )
    ])
    error_message = "Valid values for connection_strings.type are MySQL, SQLServer, SQLAzure, Custom, NotificationHub, ServiceBus, EventHub, APIHub, DocDb, RedisCache, and PostgreSQL."
  }
  # Validation for always_on in Free, F1, D1, or Shared Service Plans
  validation {
    condition = alltrue([
      for webapp in var.webapps : (
        webapp.site_config == null ||
        (
          webapp.site_config.always_on == false ||
          !contains(["Free", "F1", "D1", "Shared"], var.hosting.sku_name)
        )
      )
    ])
    error_message = "always_on must be explicitly set to false when using Free, F1, D1, or Shared Service Plans."
  }
}
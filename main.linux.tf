resource "azurerm_linux_web_app" "this" {
  for_each                                 = { for app in var.webapps : app.name => app }
  name                                     = replace(local.webapp, "asp", each.key)
  resource_group_name                      = data.azurerm_resource_group.this.name
  location                                 = data.azurerm_resource_group.this.location
  service_plan_id                          = azurerm_app_service_environment_v3.this.id
  client_affinity_enabled                  = each.value.client_affinity_enabled
  client_certificate_enabled               = each.value.client_certificate_enabled
  ftp_publish_basic_authentication_enabled = each.value.ftp_publish_basic_authentication_enabled
  https_only                               = each.value.https_only
  public_network_access_enabled            = false
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }
  key_vault_reference_identity_id = azurerm_user_assigned_identity.this.principal_id

  app_settings = each.value.app_settings
  site_config {
    always_on             = each.value.site_config.always_on
    api_definition_url    = try(each.value.site_config.api_definition_url, null)
    api_management_api_id = try(each.value.site_config.api_management_api_id, null)
    app_command_line      = try(each.value.site_config.app_command_line, null)
    dynamic "auto_heal_settings" {
      for_each = try(each.value.site_config.auto_heal_settings, {})
      content {
        status = auto_heal_settings.value.status
        dynamic "actions" {
          for_each = auto_heal_settings.value.actions
          content {
            action_type                = actions.value.action_type
            is_enabled                 = actions.value.is_enabled
            min_process_execution_time = actions.value.min_process_execution_time
          }
        }
      }
      container_registry_use_managed_identity       = try(each.value.site_config.container_registry_use_managed_identity, null)
      container_registry_managed_identity_client_id = try(each.value.site_config.container_registry_use_managed_identity, false) ? null : azurerm_user_assigned_identity.this.principal_id
      cors                                          = try(each.value.site_config.cors, null)
      default_documents                             = try(each.value.site_config.default_documents, null)
      ftps_state                                    = each.value.site_config.ftps_state
      health_check_path                             = try(each.value.site_config.health_check_path, null)
      health_check_eviction_time_in_minutes         = try(each.value.site_config.health_check_eviction_time_in_minutes, null)
      http2_enabled                                 = each.value.site_config.http2_enabled
      dynamic "ip_restriction" {
        for_each = try(each.value.site_config.ip_restriction, {})
        content {
          action     = ip_restriction.value.action
          ip_address = ip_restriction.value.ip_address
          priority   = ip_restriction.value.priority
        }
      }
      dynamic "scm_ip_restriction" {
        for_each = try(each.value.site_config.scm_ip_restriction, {})
        content {
          action     = scm_ip_restriction.value.action
          ip_address = scm_ip_restriction.value.ip_address
          priority   = scm_ip_restriction.value.priority
        }
      }
      ip_restriction_default_action     = "Deny"
      scm_ip_restriction_default_action = "Deny"
      load_balancing_mode               = each.value.site_config.load_balancing_mode
      dynamic "connection_string" {
        for_each = try(each.value.site_config.connection_string, {})
        content {
          name  = connection_string.value.name
          type  = connection_string.value.type
          value = connection_string.value.value
        }
      }
    }
  }
}
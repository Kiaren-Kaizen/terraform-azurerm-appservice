locals {
  primary_region_private_endpoint              = "${module.primary_region_naming.private_endpoint.name}${module.primary_region_naming.private_endpoint.dashes ? "-" : ""}001"
  secondary_region_private_endpoint            = "${module.secondary_region_naming.private_endpoint.name}${module.secondary_region_naming.private_endpoint.dashes ? "-" : ""}001"
  primary_region_private_endpoint_connection   = "${module.primary_region_naming.private_service_connection.name}${module.primary_region_naming.private_service_connection.dashes ? "-" : ""}001"
  secondary_region_private_endpoint_connection = "${module.secondary_region_naming.private_service_connection.name}${module.secondary_region_naming.private_service_connection.dashes ? "-" : ""}001"
  primary_region_subnet                        = "${module.primary_region_naming.subnet.name}${module.primary_region_naming.subnet.dashes ? "-" : ""}001"
  secondary_region_subnet                      = "${module.secondary_region_naming.subnet.name}${module.secondary_region_naming.subnet.dashes ? "-" : ""}001"
  asp                                          = "${module.primary_region_naming.app_service_plan.name}${module.primary_region_naming.app_service_plan.dashes ? "-" : ""}001"
  ase                                          = "${module.primary_region_naming.app_service_environment.name}${module.primary_region_naming.app_service_environment.dashes ? "-" : ""}001"
  webapp                                       = "${module.primary_region_naming.app_service.name}${module.primary_region_naming.app_service.dashes ? "-" : ""}001"
  uami                                         = "${module.primary_region_naming.user_assigned_identity.name}${module.primary_region_naming.user_assigned_identity.dashes ? "-" : ""}001"
  tags                                         = module.app_landing_zone_outputs.tags
  maximum_elastic_worker_count                 = can(regex("E1|E2|E3", var.hosting.sku_name)) ? var.hosting.maximum_elastic_worker_count : null
}
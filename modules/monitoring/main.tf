resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-citadel-telemetry"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
}


resource "azurerm_monitor_diagnostic_setting" "telemetry" {
  for_each                   = var.resource_ids
  name                       = "diag-${each.key}"
  target_resource_id         = each.value
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log { category_group = "allLogs" }
  metric { category = "AllMetrics" }
}
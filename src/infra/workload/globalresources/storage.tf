# This "public" storage account is being used for to store catalog data. It is deployed as read-access geo-redundant
resource "azurerm_storage_account" "global" {
  name                     = "${local.prefix}globalst"
  resource_group_name      = azurerm_resource_group.global.name
  location                 = azurerm_resource_group.global.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGZRS"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = true

  blob_properties {
    versioning_enabled = true
  }

  tags = local.default_tags
}

# Storage container to store catalog item images
resource "azurerm_storage_container" "images" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.global.name
  container_access_type = "blob"
}

# Empty Storage Blob for Azure Front Door health checks
resource "azurerm_storage_blob" "healthcheck" {
  name                   = "health.check"
  storage_account_name   = azurerm_storage_account.global.name
  storage_container_name = azurerm_storage_container.images.name
  type                   = "Block"
  source_content         = "" # empty file
}

####################################### PUBLIC STORAGE DIAGNOSTIC SETTINGS #######################################

# Use this data source to fetch all available log and metrics categories. We then enable all of them
data "azurerm_monitor_diagnostic_categories" "global_public" {
  resource_id = azurerm_storage_account.global.id
}

resource "azurerm_monitor_diagnostic_setting" "storage_global" {
  name                       = "storageladiagnostics"
  target_resource_id         = azurerm_storage_account.global.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.global.id

  dynamic "log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.global_public.logs

    content {
      category = entry.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = 30
      }
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.global_public.metrics

    content {
      category = entry.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = 30
      }
    }
  }
}

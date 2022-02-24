# Add any secrets that should go into Key Vault to this list. Key is the name of the secret in Key Vault
locals {
  secrets = {
    "Frontend-SenderEventHubConnectionString"    = azurerm_eventhub_authorization_rule.frontend_sender.primary_connection_string
    "Backend-ReaderEventHubConnectionString"     = azurerm_eventhub_authorization_rule.backend_reader.primary_connection_string
    "Backend-ReaderEventHubConsumerGroupName"    = azurerm_eventhub_consumer_group.backendworker.name
    "EventHub-BackendqueueName"                  = azurerm_eventhub.backendqueue.name
    "StorageAccount-ConnectionString"            = azurerm_storage_account.private.primary_connection_string
    "StorageAccount-EhCheckpointContainerName"   = azurerm_storage_container.deployment_eventhub_checkpoints.name
    "StorageAccount-Healthservice-ContainerName" = azurerm_storage_container.deployment_healthservice.name
    "StorageAccount-Healthservice-BlobName"      = local.health_blob_name
    "Global-StorageAccount-ConnectionString"     = data.azurerm_storage_account.global.primary_connection_string
    "APPINSIGHTS-INSTRUMENTATIONKEY"             = data.azurerm_application_insights.stamp.instrumentation_key
    "CosmosDb-Endpoint"                          = data.azurerm_cosmosdb_account.global.endpoint
    "CosmosDb-ApiKey"                            = data.azurerm_cosmosdb_account.global.primary_key
    "CosmosDb-DatabaseName"                      = var.cosmosdb_database_name
    "API-Key"                                    = var.api_key
  }
}

resource "azurerm_key_vault_secret" "secrets" {
  # Every secret is depended on a) the access policy for the deploying service principal being created and b) - only when running in private mode - on the build agent private endpoint being up and running
  depends_on = [azurerm_key_vault_access_policy.devops_pipeline_all]
  # Loop through the list of secrets from above
  for_each     = local.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.stamp.id
}

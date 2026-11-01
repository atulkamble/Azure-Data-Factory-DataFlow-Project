resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  suffix          = random_string.suffix.result
  storage_name    = "stadf${local.suffix}"
  factory_name    = "${var.project_name}-${local.suffix}"
  resource_group  = "rg-${var.project_name}-${local.suffix}"
  linked_service  = "ls_blob_storage"
  source_dataset  = "ds_employees_raw"
  sink_dataset    = "ds_employees_clean"
  data_flow       = "df_employee_transform"
  pipeline        = "pl_employee_transform"
}

resource "azurerm_resource_group" "lab" {
  name     = local.resource_group
  location = var.location
}

resource "azurerm_storage_account" "lab" {
  name                            = local.storage_name
  resource_group_name             = azurerm_resource_group.lab.name
  location                        = azurerm_resource_group.lab.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "raw" {
  name                  = "raw"
  storage_account_id    = azurerm_storage_account.lab.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "clean" {
  name                  = "clean"
  storage_account_id    = azurerm_storage_account.lab.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "employees" {
  name                   = "input/employees.csv"
  storage_account_name   = azurerm_storage_account.lab.name
  storage_container_name = azurerm_storage_container.raw.name
  type                   = "Block"
  source                 = "${path.module}/../sample-data/employees.csv"
  content_type           = "text/csv"
}

resource "azurerm_data_factory" "lab" {
  name                = local.factory_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "adf_storage" {
  scope                = azurerm_storage_account.lab.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.lab.identity[0].principal_id
  principal_type       = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azapi_resource" "linked_service" {
  type      = "Microsoft.DataFactory/factories/linkedservices@2018-06-01"
  name      = local.linked_service
  parent_id = azurerm_data_factory.lab.id
  body = {
    properties = merge(
      jsondecode(file("${path.module}/../linkedService/ls_blob_storage.json")).properties,
      {
        typeProperties = {
          serviceEndpoint = azurerm_storage_account.lab.primary_blob_endpoint
          accountKind     = "StorageV2"
        }
      }
    )
  }
}

resource "azapi_resource" "source_dataset" {
  type      = "Microsoft.DataFactory/factories/datasets@2018-06-01"
  name      = local.source_dataset
  parent_id = azurerm_data_factory.lab.id
  body = {
    properties = jsondecode(file("${path.module}/../dataset/ds_employees_raw.json")).properties
  }
  depends_on = [azapi_resource.linked_service]
}

resource "azapi_resource" "sink_dataset" {
  type      = "Microsoft.DataFactory/factories/datasets@2018-06-01"
  name      = local.sink_dataset
  parent_id = azurerm_data_factory.lab.id
  body = {
    properties = jsondecode(file("${path.module}/../dataset/ds_employees_clean.json")).properties
  }
  depends_on = [azapi_resource.linked_service]
}

resource "azapi_resource" "data_flow" {
  type      = "Microsoft.DataFactory/factories/dataflows@2018-06-01"
  name      = local.data_flow
  parent_id = azurerm_data_factory.lab.id
  body = {
    properties = jsondecode(file("${path.module}/../dataflow/df_employee_transform.json")).properties
  }
  depends_on = [azapi_resource.source_dataset, azapi_resource.sink_dataset]
}

resource "azapi_resource" "pipeline" {
  type      = "Microsoft.DataFactory/factories/pipelines@2018-06-01"
  name      = local.pipeline
  parent_id = azurerm_data_factory.lab.id
  body = {
    properties = jsondecode(file("${path.module}/../pipeline/pl_employee_transform.json")).properties
  }
  depends_on = [azapi_resource.data_flow, azurerm_role_assignment.adf_storage, azurerm_storage_blob.employees]
}

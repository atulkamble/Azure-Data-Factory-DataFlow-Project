output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "data_factory_name" {
  value = azurerm_data_factory.lab.name
}

output "storage_account_name" {
  value = azurerm_storage_account.lab.name
}

output "pipeline_name" {
  value = azapi_resource.pipeline.name
}

output "source_blob" {
  value = "raw/input/employees.csv"
}

output "sink_prefix" {
  value = "clean/output/"
}

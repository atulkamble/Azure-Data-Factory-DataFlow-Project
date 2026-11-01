variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "centralindia"
}

variable "project_name" {
  description = "Prefix for Azure resources"
  type        = string
  default     = "adf-dataflow"
}

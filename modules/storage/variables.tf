variable "rg_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "pe_subnet_id" {
  type        = string
  description = "The ID of the subnet where the Private Endpoint tunnel lives."
}

variable "identity_principal_id" {
  type        = string
  default     = null
  description = "The ID of the App's badge for identity-access."
}
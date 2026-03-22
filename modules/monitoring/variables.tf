variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_ids" {
  type        = map(string)
  description = "The map of all Citadel buildings that the CCTV needs to watch."
}
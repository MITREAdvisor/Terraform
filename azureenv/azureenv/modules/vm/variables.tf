variable "app_location" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vnet_name" {
  type = string
}


variable "address_spaces" {
  description = "The list of the address spaces that is used by the virtual network."
  type        = list(string)
  default     = []
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vm_names" {
  description = "Name of the vm to create."
  type        = list(string)
  default     = []
}

variable "vm_size" {
  type = string
}

module "vm" {
  source         = "/Users/ecisneros/Projects/NTD/azure-devops/azureenv/modules/vm"
  app_location   = "usgovvirginia"
  vnet_name      = "NTD_TEST"
  project_name   = "Sprint-${terraform.workspace}"
  address_spaces = ["10.3.0.0/16", "10.4.0.0/16"]
  vm_names       = ["Server1", "Server2"]
  vm_size        = "Standard_D2s_v4"
}



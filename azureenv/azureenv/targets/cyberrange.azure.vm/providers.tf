/*********************************** Generic HCL  code for compute cluster ***************************/
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.66.0"
    }
  }
}

provider "azurerm" {
  features {}
}

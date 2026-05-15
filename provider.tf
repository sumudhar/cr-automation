terraform {
  required_version = ">= 1.0.0"

  required_providers {
    # Use the IBM Cloud provider from the IBM namespace on the registry
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.12.0"
    }
  }
}

provider "ibm" {
  # Use your variable or env-based API key and region
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}
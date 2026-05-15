variable "ibmcloud_api_key" {
  type        = string
  description = "API key used to create the toolchain."
  sensitive   = true
}

variable "resource_group" {
  type    = string
  default = "murali-test"
}

variable "owner_id" {
  type    = string
  default = "murali.tirupati@ibm.com"

}

variable "auth_type" {
  type    = string
  default = "pat"
}

variable "ghe_token" {
  type      = string
  sensitive = true
}

variable "git_id" {
  type    = string
  default = "integrated"
}
variable "region" {
  type    = string
  default = "us-south"
}

variable "cd_tool_chain_name" {
  type    = string
  default = "cr-automation-toolchain"
}

variable "repo_data" {
  description = "List of repositories with name and URL"
  type = list(object({
    name     = string
    repo_url = string
  }))
  default = [
    {
      name     = "cr-automation-repo"
      repo_url = "https://github.ibm.com/Murali-Tirupati/change-demo.git"
    },
    {
      name     = "compliance-repo"
      repo_url = "https://github.ibm.com/one-pipeline/compliance-pipelines.git"
    }
  ]
}
variable "private_worker_name" {
  type    = string
  default = "cr-automation-worker"
}

variable "github_event_listener" {
  type    = string
  default = "cr-automation-listener"
}
variable "github_event_trigger" {
  type    = string
  default = "cr-automation-trigger"
}
variable "pipeline_name" {
  type    = string
  default = "cr-automation-pipeline"
}

variable "repo_name" {
  type    = string
  default = "change-demo"
}
variable "branch_name" {
  type    = string
  default = "main"
}
variable "pipeline_trigger_name" {
  type    = string
  default = "cr-automation-pipeline-trigger"
}
variable "compliance_repo_url" {
  type    = string
  default = "https://github.ibm.com/one-pipeline/compliance-pipelines"
}
variable "change_api_key" {
  type      = string
  sensitive = true
}
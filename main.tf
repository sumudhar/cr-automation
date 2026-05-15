############################################
# Global Tekton Pipeline Properties
############################################
locals {
  global_pipeline_properties = {
    ibm-identity-url           = "https://iam.cloud.ibm.com/identity"
    pnp-base-url               = "https://pnp-api-oss.cloud.ibm.com/changemgmt/api/v3"
    github-token               = var.ghe_token
    pipeline-config-branch     = "main"
    app-repo                   = "https://github.ibm.com/Murali-Tirupati/change-demo.git"
    compliance-repo            = "https://github.ibm.com/one-pipeline/compliance-pipelines.git"
    pipeline-config-repo       = "https://github.ibm.com/Murali-Tirupati/change-demo.git"
    ibm-change-api-key         = var.change_api_key
    ibmcloud-api-key           = var.ibmcloud_api_key
    evidence-repo              = "https://github.ibm.com/Murali-Tirupati/evidence-repo"
    incident-repo              = "https://github.ibm.com/Murali-Tirupati/compliance-inventory"
    inventory-repo             = "https://github.ibm.com/Murali-Tirupati/compliance-inventory"
    target-environment         = "prod"
    target-environment-detail  = "production"
    target-environment-purpose = "production"
    source-environment         = "main"
    change-dispaly-url         = "https://watson.service-now.com/nav_to.do?uri=change_request.do?sys_id="
  }
}

# ------------------------------------------------------------
# Use the existing Resource Group (depends on the check)
# ------------------------------------------------------------
data "ibm_resource_group" "existing" {
  name       = var.resource_group
  
}

# ------------------------------------------------------------
# Create Toolchain
# ------------------------------------------------------------
resource "ibm_cd_toolchain" "cd_toolchain" {
  name              = var.cd_tool_chain_name
  resource_group_id = data.ibm_resource_group.existing.id
}

# ------------------------------------------------------------
# GitHub Consolidated Integration
# ------------------------------------------------------------
resource "ibm_cd_toolchain_tool_githubconsolidated" "repo" {
  for_each     = { for r in var.repo_data : r.name => r }
  toolchain_id = ibm_cd_toolchain.cd_toolchain.id
  name         = each.value.name

  initialization {
    git_id   = var.git_id
    repo_url = each.value.repo_url
    owner_id = var.owner_id
    type     = "link"
  }

  parameters {
    toolchain_issues_enabled = true
    auth_type                = var.auth_type
    api_token                = var.ghe_token
  }
}

# ------------------------------------------------------------
# DevOps Insights Integration
# ------------------------------------------------------------
resource "ibm_cd_toolchain_tool_devopsinsights" "devops_insights" {
  toolchain_id = ibm_cd_toolchain.cd_toolchain.id
}

# ------------------------------------------------------------
# Tekton Pipeline Tool
# ------------------------------------------------------------
resource "ibm_cd_toolchain_tool_pipeline" "pipeline_tool" {
  toolchain_id = ibm_cd_toolchain.cd_toolchain.id
  name         = "cr-automation-pipeline"

  parameters {
    name = var.pipeline_name
  }
}

# ------------------------------------------------------------
# Tekton Pipeline Instance
# ------------------------------------------------------------
resource "ibm_cd_tekton_pipeline" "pipeline_instance" {
  depends_on = [
    ibm_cd_toolchain_tool_pipeline.pipeline_tool,
    ibm_cd_toolchain_tool_githubconsolidated.repo
  ]

  pipeline_id            = ibm_cd_toolchain_tool_pipeline.pipeline_tool.tool_id
  enable_notifications   = false
  enable_partial_cloning = false

  worker {
    id = "public"
  }
}

# ------------------------------------------------------------
# Tekton Pipeline Definition (from compliance-pipelines repo)
# ------------------------------------------------------------
resource "ibm_cd_tekton_pipeline_definition" "pipeline_definition" {
  depends_on  = [ibm_cd_toolchain_tool_githubconsolidated.repo]
  pipeline_id = ibm_cd_toolchain_tool_pipeline.pipeline_tool.tool_id

  source {
    type = "git"

    properties {
      url    = var.compliance_repo_url # "https://github.ibm.com/one-pipeline/compliance-pipelines.git"
      branch = "master"
      path   = "definitions"
    }
  }
}

##############################################################
# 11. Create: Creating Global properties for Tekton Pipeline
##############################################################
resource "ibm_cd_tekton_pipeline_property" "global_props" {
  for_each = local.global_pipeline_properties

  pipeline_id = ibm_cd_toolchain_tool_pipeline.pipeline_tool.tool_id
  name        = each.key
  type        = contains(["ibm-change-api-key", "github-token", "ibmcloud-api-key"], each.key) ? "secure" : "text"
  value       = each.value
}

# ------------------------------------------------------------
# (Optional) Outputs
# ------------------------------------------------------------
output "resource_group_id" {
  value       = data.ibm_resource_group.existing.id
  description = "ID of the existing IBM Cloud Resource Group used for the toolchain."
}

output "toolchain_id" {
  value       = ibm_cd_toolchain.cd_toolchain.id
  description = "ID of the created toolchain."
}

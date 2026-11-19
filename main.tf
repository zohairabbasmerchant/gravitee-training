terraform {
  required_providers {
    apim = {
      source  = "gravitee-io/apim"
      version = "~> 1.2.0"
    }
  }
}

variable "apim_cloud_token" {
  type      = string
  sensitive = true
}

provider "apim" {
  cloud_auth = var.apim_cloud_token
}

resource "apim_apiv4" "partner_multi_tenant" {
  organization_id = "38907341-741d-42af-9073-41741de2af61"
  environment_id  = "b8135005-7573-4ed5-9350-0575739ed56a"
  hrid            = "partner-iac-zohair"
  name            = "Partner IaC Multi-Tenant API - Zohair"
  description     = "Automated via Terraform for Exercise 2.8"
  version         = "1.0.0"
  type            = "PROXY"
  state           = "STARTED"
  lifecycle_state = "PUBLISHED"
  visibility      = "PUBLIC"

  tags = ["partner-internal"]

  listeners = [
    {
      http = {
        type = "HTTP"
        paths = [
          {
            path = "/iac-zohair"
          }
        ]
        entrypoints = [
          {
            type = "http-proxy"
          }
        ]
      }
    }
  ]

  endpoint_groups = [
    {
      name = "multi-tenant-backends"
      type = "http-proxy"
      endpoints = [
        {
          name    = "usa-backend"
          type    = "http-proxy"
          tenants = ["usa"]
          configuration = jsonencode({
            target = "https://api.gravitee.io/echo?tenant=usa"
          })
        },
        {
          name    = "eu-backend"
          type    = "http-proxy"
          tenants = ["eu"]
          configuration = jsonencode({
            target = "https://api.gravitee.io/echo?tenant=eu"
          })
        }
      ]
    }
  ]

  plans = [
    {
      hrid   = "keyless-plan"
      name   = "Open Keyless Plan"
      status = "PUBLISHED"
      type   = "API"
      mode   = "STANDARD"
      security = {
        type = "KEY_LESS"
      }
    }
  ]
}
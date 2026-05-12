---
marp: true
title: Deployment to azure via terraform files
paginate: true
size: 16:9
---

# Slide 1: Introduction

Terraform files can be used to deploy an kind of (virtual) infrastruture via structured files
That means I can create sql servers, web servers, app registrations, network configurations and access rights, just by putting a description of these in files i.e. terraform files

In this project I want to deploy a angular web (client) application in conjuction with a dotnet backend that is uses to access the storage layer (e.g. sql) in secure way. 


---

# Slide 2: Architecture Overview

| Component | Azure Service | Terraform resource |
|---|---|---|
| Angular SPA | Static Web Apps (Free) | `azurerm_static_web_app` |
| .NET 9 API | App Service (Linux B1) | `azurerm_linux_web_app` |
| Resource group | Resource Group | `azurerm_resource_group` |

All resources share the prefix `partsdb-prod-` and live in **West Europe**.

---

# Slide 3: Implementation Details

**Terraform** (`infrastructure/`) manages all Azure resources as code.

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

**CI/CD** (GitHub Actions) automatically deploys on push to `main`:
- `deploy-backend.yml` → publishes the .NET 9 API via publish-profile
- `deploy-frontend.yml` → builds Angular and deploys to Static Web Apps via API token

Required GitHub secrets: `AZURE_BACKEND_PUBLISH_PROFILE`, `AZURE_STATIC_WEB_APP_API_TOKEN`

---

# Slide 4: Conclusion

**First-time deployment checklist**

1. Copy `infrastructure/terraform.tfvars.example` → `terraform.tfvars` and fill in values
2. Run `terraform init && terraform apply` to provision Azure resources
3. Download the App Service **publish profile** and add as `AZURE_BACKEND_PUBLISH_PROFILE` secret
4. Copy the Static Web App **API token** (Terraform output: `static_web_app_api_key`) and add as `AZURE_STATIC_WEB_APP_API_TOKEN` secret
5. Push to `main` — GitHub Actions handles all subsequent deployments automatically

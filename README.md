# terraform-azurerm-app-service-key-vault-access-policy
Terraform module designed to add key vault access poicy from Azure PaaS Service and Function Apps MSI (Managed Service Identities).

## Usage

### Sample
Include this repository as a module in your existing terraform code:

```hcl
data "azurerm_key_vault" "test" {
  name                = "mykeyvault"
  resource_group_name = "some-resource-group"
}

resource "azurerm_resource_group" "test" {
  name     = "azure-functions-cptest-rg"
  location = "westus2"
}

resource "azurerm_storage_account" "test" {
  name                     = "functionsapptestsa"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  location                 = "${azurerm_resource_group.test.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "azure-functions-test-service-plan"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "test" {
  name                      = "test-azure-functions"
  location                  = "${azurerm_resource_group.test.location}"
  resource_group_name       = "${azurerm_resource_group.test.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.test.id}"
  storage_connection_string = "${azurerm_storage_account.test.primary_connection_string}"
  identity {
    type = "SystemAssigned"
  }
}

# Add KeyVault Policies from App Services MSI (Managed Services Identities)
module "eg_key_vault_access_policies_fn_apps" {
  source     = "git::https://github.com/transactiveltd/terraform-azurerm-app-service-key-vault-access-policy.git?ref=master"

  access_policy_count = 1

  identities              = "${azurerm_function_app.test.identity}"
  key_permissions         = ["get","list"]
  secret_permissions      = ["get","list"]
  certificate_permissions = ["get","list"]

  key_vault_name   = "${data.azurerm_key_vault.test.name}"
  key_vault_resource_group_name = "${data.azurerm_key_vault.test.resource_group_name}"
}
```

This will create Key Vault access policies for the number of identies provided.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access_policy_count | Count, Count must be of equal length to `identities` | number | - | yes |
| identities | An identity blocks, which contains the Managed Service Identity information for the App Services. See Terraform Azure Provider resource [azurerm_function_app](https://www.terraform.io/docs/providers/azurerm/r/function_app.html#identity-1) or [azurerm_app_service](https://www.terraform.io/docs/providers/azurerm/r/app_service.html#identity-1) for details. | list of maps | - | yes |
| key_permissions | List of key permissions, must be one or more from the following: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify and wrapKey. | list | `["get","list",]` | yes |
| secret_permissions | List of secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set. | list | `["get","list",]` | yes |
| certificate_permissions | List of certificate permissions, must be one or more from the following: create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, setissuers and update. | list | `["get","list",]` | yes |
| key_vault_name | Key Vault name| string | - | yes |
| key_vault_resource_group_name | Key Vault Resource Group name, e.g. `testing-service-rg` | string | - | yes |

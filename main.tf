data "azurerm_resource_group" "default" {
  name = "${var.key_vault_resource_group_name}"
}

data "azurerm_key_vault" "default" {
  name                = "${var.key_vault_name}"
  resource_group_name = "${data.azurerm_resource_group.default.name}"
}

resource "azurerm_key_vault_access_policy" "default" {
  count               = "${var.access_policy_count}"
  vault_name          = "${data.azurerm_key_vault.default.name}"
  resource_group_name = "${data.azurerm_key_vault.default.resource_group_name}"

  tenant_id      = "${lookup(element(element(var.identities, count.index),0),"tenant_id")}"
  object_id      = "${lookup(element(element(var.identities, count.index),0),"object_id")}"
  application_id = "${lookup(element(element(var.identities, count.index),0),"object_id")}"

  key_permissions = "${var.key_permissions}"

  secret_permissions      = "${var.secret_permissions}"
  certificate_permissions = "${var.certificate_permissions}"
}

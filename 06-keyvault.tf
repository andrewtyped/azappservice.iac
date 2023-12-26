resource "azurerm_key_vault" "azappsvc_keyvault" {
    name =var.key_vault_name
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tenant_id = data.azuread_client_config.current.tenant_id
    enabled_for_disk_encryption = true
    soft_delete_retention_days = 7
    purge_protection_enabled = true

    sku_name = "standard"

    access_policy = [{
        tenant_id = data.azuread_client_config.current.tenant_id
        object_id = data.azuread_client_config.current.object_id
        application_id = null

        key_permissions = ["Get"],

        secret_permissions = ["Get", "List", "Set"],

        storage_permissions = ["Get"]

        certificate_permissions = ["Get"]
    }]


}


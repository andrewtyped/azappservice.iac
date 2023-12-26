resource "azuread_application" "azappsvc_deployer_app" {
    display_name = "azappsvc_deployer_app"
    owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "azappsvc_deployer_spn" {
    client_id = azuread_application.azappsvc_deployer_app.client_id
    app_role_assignment_required = false
    owners = [data.azuread_client_config.current.object_id]

    feature_tags {
      enterprise = true
      gallery = true
    }
}

resource "azurerm_role_assignment" "azappsvc_resource_group_access" {
  scope                = "${azurerm_resource_group.rg.id}"
  role_definition_name = "Contributor"
  principal_id         = "${azuread_service_principal.azappsvc_deployer_spn.id}"
}
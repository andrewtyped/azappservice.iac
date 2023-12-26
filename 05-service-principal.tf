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

resource "azuread_service_principal_password" "azappsvc_deployer_spn_secret" {
  service_principal_id = azuread_service_principal.azappsvc_deployer_spn.object_id
}
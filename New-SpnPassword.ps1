param(
    [string]
    $AppId = '',

    [string]
    $KeyVault = ''
)

$SecretJson = & az ad app credential reset --id $AppId --display-name "DeploymentCredential" --years 1

$Secret = $SecretJson | ConvertFrom-Json

& az keyvault secret set --vault-name $KeyVault --name 'DeploymentClientId' --value $AppId

& az keyvault secret set --vault-name $KeyVault --name 'DeploymentClientSecret' --value $Secret.password
resource "azurerm_service_plan" "svc_plan" {
    name = var.svc_plan_name
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    os_type = "Linux"
    sku_name = var.svc_plan_sku
    worker_count = 1
    per_site_scaling_enabled = false
    zone_balancing_enabled = false
    tags = merge(var.common_tags)
}

resource "azurerm_virtual_network" "vnet" {
    name = var.vnet_name
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet"  "subnet" {
    name = var.subnet_name
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.0.0/16"]
}

resource "azurerm_storage_account" "appstorage" {
    name = var.storage_account_name
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_tier = "Standard"
    account_replication_type = "LRS"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"

    identity {
      type = "SystemAssigned"
    }

    network_rules {
      default_action = "Deny"
      ip_rules = [var.my_ip_address]
      virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
      bypass = ["AzureServices"]
    }
}

resource "azurerm_storage_container" "app1storagecontainer" {
    name = "${var.app_name_prefix}-1"
    storage_account_name = azurerm_storage_account.appstorage.name
    container_access_type = "private"
}

resource "time_rotating" "main" {
  rotation_rfc3339 = null
  rotation_years   = 2

  triggers = {
    end_date = null
    years    = 2
  }
}

data "azurerm_storage_account_blob_container_sas" "app1storagecontainer_sas" {
    connection_string = azurerm_storage_account.appstorage.primary_connection_string
    container_name = azurerm_storage_container.app1storagecontainer.name

    start = timestamp()
    expiry = time_rotating.main.rotation_rfc3339

    permissions {
      read = true
      write = true
      add = true
      create = true
      delete = true
      list = true
    }

    cache_control = "max-age=5"
    content_disposition = "inline"
    content_encoding = "deflate"
    content_language = "en-US"
    content_type = "application/json"
}

resource "azurerm_linux_web_app" "app1" {
    name = "${var.app_name_prefix}-1"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    service_plan_id = azurerm_service_plan.svc_plan.id
    https_only = true
    public_network_access_enabled = true
    virtual_network_subnet_id = azurerm_subnet.subnet.id
    storage_account {
      name = "WebsiteStorageConnectionString"
      account_name = azurerm_storage_account.appstorage.name
      access_key = azurerm_storage_account.appstorage.primary_access_key
      share_name = azurerm_storage_container.app1storagecontainer.name
      type = "AzureBlob"

    }

    logs {
      detailed_error_messages = true
      failed_request_tracing = true
      application_logs {
        azure_blob_storage {
          level = "Information"
          sas_url = format("https://${azurerm_storage_account.appstorage.name}.blob.core.windows.net/${azurerm_storage_container.app1storagecontainer.name}%s",data.azurerm_storage_account_blob_container_sas.app1storagecontainer_sas.sas)
          retention_in_days = 30
        }
        file_system_level = "Information"
      }
      http_logs {
        azure_blob_storage {
          sas_url = format("https://${azurerm_storage_account.appstorage.name}.blob.core.windows.net/${azurerm_storage_container.app1storagecontainer.name}%s",data.azurerm_storage_account_blob_container_sas.app1storagecontainer_sas.sas)
          retention_in_days = 30
        }
      }
    }

    connection_string {
      name = "StorageAccount"
      type = "Custom"
      value = azurerm_storage_account.appstorage.primary_connection_string
    }

    identity {
      type = "SystemAssigned"
    }

    site_config {
      always_on = true
      application_stack {
        dotnet_version = "8.0"
      }
    }
}
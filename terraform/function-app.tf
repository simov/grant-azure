resource "azurerm_resource_group" "serverless" {
  name     = "${var.app}-${var.os_type}"
  location = var.region
}

resource "azurerm_storage_account" "bucket" {
  name                     = replace(var.app, "-", "")
  resource_group_name      = azurerm_resource_group.serverless.name
  location                 = azurerm_resource_group.serverless.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
  account_kind = "Storage"
}

resource "azurerm_app_service_plan" "consumption" {
  name                = "${var.app}-${var.os_type}"
  location            = azurerm_resource_group.serverless.location
  resource_group_name = azurerm_resource_group.serverless.name

  # BUG: requires Linux for linux apps, but writes FunctionApp to state
  # kind                = var.os_type == "linux" ? "Linux" : "FunctionApp"
  kind                = "FunctionApp"
  reserved            = var.os_type == "linux" ? true : false

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "grant" {
  name                       = var.app
  location                   = azurerm_resource_group.serverless.location
  resource_group_name        = azurerm_resource_group.serverless.name
  app_service_plan_id        = azurerm_app_service_plan.consumption.id
  storage_account_name       = azurerm_storage_account.bucket.name
  storage_account_access_key = azurerm_storage_account.bucket.primary_access_key

  os_type                = var.os_type == "linux" ? "linux" : null
  enable_builtin_logging = false

  version = "~3"
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "~14"
    FIREBASE_PATH = var.firebase_path
    FIREBASE_AUTH = var.firebase_auth
  }
}

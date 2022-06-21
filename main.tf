provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "Shivani-resources"
  location = "East US"
}

resource "azurerm_dev_test_lab" "example" {
  name                = "Shivani-devtestlab"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_dev_test_virtual_network" "example" {
  name                = "Shivani-network"
  lab_name            = azurerm_dev_test_lab.example.name
  resource_group_name = azurerm_resource_group.example.name

  subnet {
    use_public_ip_address           = "Allow"
    use_in_virtual_machine_creation = "Allow"
  }
}

resource "azurerm_dev_test_windows_virtual_machine" "example" {
  name                   = "Shivani-vm"
  lab_name               = azurerm_dev_test_lab.example.name
  resource_group_name    = azurerm_resource_group.example.name
  location               = azurerm_resource_group.example.location
  size                   = "Standard_DS2"
  username               = "Shivani"
  password               = "Shiv10@19999"
  lab_virtual_network_id = azurerm_dev_test_virtual_network.example.id
  lab_subnet_name        = azurerm_dev_test_virtual_network.example.subnet[0].name
  storage_type           = "Premium"

  gallery_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_dev_test_policy" "example" {
  name                = "LabVmCount"
  policy_set_name     = "default"
  lab_name            = azurerm_dev_test_lab.example.name
  resource_group_name = azurerm_resource_group.example.name
  threshold           = "999"
  evaluator_type      = "MaxValuePolicy"

  tags = {
    "environment" = "production"
  }
}

resource "azurerm_dev_test_schedule" "example" {
  name                = "LabVmAutoStart"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  lab_name            = azurerm_dev_test_lab.example.name

  weekly_recurrence {
    time      = "1100"
    week_days = ["Monday", "Tuesday"]
  }

  time_zone_id = "Pacific Standard Time"
  task_type    = "LabVmsStartupTask"

  notification_settings {
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "example" {
  virtual_machine_id = azurerm_dev_test_windows_virtual_machine.example.id
  location           = azurerm_resource_group.example.location
  enabled            = true

  daily_recurrence_time = "1100"
  timezone              = "Pacific Standard Time"

  notification_settings {
    enabled         = true
    time_in_minutes = "60"
  }
}
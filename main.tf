provider "azurerm" { }

#sorgt dafür, dass das state-file nicht lokal sondern im container liegt.
terraform {
  backend "azurerm" {
  resource_group_name = "jambitiac"
  storage_account_name = "jambitiac"
  container_name = "tfstate"
  key = "cschaffe.terraform.tstate"
  }

}

resource "azurerm_resource_group" "test" {
  name = "cschaffe-tf-target"
  location = "westeurope"
}


#-----------------------------------------------------------------------
# https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html
#-----------------------------------------------------------------------

#Assume that custom image has been already created in the 'customimage' resource group
data "azurerm_resource_group" "image" {
  name = "cschaffe-test"
}

data "azurerm_image" "image" {
  name                = "cschaffe-aic-1524570922"
  resource_group_name = "${data.azurerm_resource_group.image.name}"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "test" {
  name                = "acctni"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.test.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctvm"
  location              = "${azurerm_resource_group.test.location}"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    id="${data.azurerm_image.image.id}"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }


  os_profile {
    computer_name  = "${data.azurerm_image.image.name}-vm"
    admin_username = "jambitadmin"
    admin_password = "jambitadmin123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}

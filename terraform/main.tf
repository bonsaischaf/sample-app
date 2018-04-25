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
  name = "cschaffe-test"
  location = "westeurope"
}

##       ##   ###        ###
 ##     ##    ## ##    ## ##
   ## ##      ##  ## ##   ##
    ###       ##   ###    ##
     #        ##    #     ##

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
  # count wird angelegt und auf var.sample-app-count (idx=0, val=1) initialisiert.
  # Beim nächsten Zugriff wird ein zweiter Parameter count angelegt (idx+=1, val=1)...

  #count ist ein terraform-keyword und bescshreibt, wieviele Instanzen davon angelegt werden sollen.
  count               = "${var.sample-app-count}"
  name                = "acctni-${count.index}"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.test.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.test.*.id[count.index]}"
  }
}

resource "azurerm_virtual_machine" "test" {
  count                 = "${var.sample-app-count}"
  name                  = "acctvm-${count.index}"
  location              = "${azurerm_resource_group.test.location}"
  resource_group_name   = "${azurerm_resource_group.test.name}"

  #Alle heissen test. Wir wollen aber die i-te Instanz. deswegen wird aus xyz.test.* eine Liste aller
  # azurerm_network_interface instanzen gezogen und indiziert. in ${...} steht terraform code.
  network_interface_ids = ["${azurerm_network_interface.test.*.id[count.index]}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    id="${data.azurerm_image.image.id}"
  }

  storage_os_disk {
    # in azure MUSS jede Instanz eine eigene OS-Disk haben.
    # Sie ist eine inline Resource und wird damit automatisch angelegt
    # !!! Es gibt aber einen Namenskonflikt, deswegen muss die Benamung eindeutig sein:
    name              = "myosdisk-${count.index}"
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


#-----------------------------------------------------------------------
# https://www.terraform.io/docs/providers/azurerm/r/public_ip.html
#-----------------------------------------------------------------------

resource "azurerm_public_ip" "test" {
  count                        = "${var.sample-app-count}"
  name                         = "PublicIp1-${count.index}"
  location                     = "${azurerm_resource_group.test.location}"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "staging"
  }
}


#-----------------------------------------------------------------------
#https://www.terraform.io/docs/providers/azurerm/r/network_security_group.html
#-----------------------------------------------------------------------


resource "azurerm_network_security_group" "test" {
  name                = "acceptanceTestSecurityGroup1"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  security_rule {
    name                       = "AllowHttp"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 199
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags {
    environment = "Production"
  }
}

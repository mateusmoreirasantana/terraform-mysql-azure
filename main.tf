terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
    skip_provider_registration = false
    features {}
}

resource "azurerm_resource_group" "terraformRG" {
  name     = "tFResourceGroupES21"
  location = "westus2"
}

resource "azurerm_virtual_network" "terraformNW" {
  name                = "vNetES21"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terraformRG.location
  resource_group_name = azurerm_resource_group.terraformRG.name

   tags = {
        environment = "Atividade 2 ES21 Infra"
    }
}

resource "azurerm_subnet" "terraformSN" {
  name                 = "subNetES21"
  resource_group_name  = azurerm_resource_group.terraformRG.name
  virtual_network_name = azurerm_virtual_network.terraformNW.name
  address_prefixes     = ["10.0.2.0/24"]
   
}

resource "azurerm_public_ip" "terraformPubIp" {
  name                = "publicIpES21"
  resource_group_name = azurerm_resource_group.terraformRG.name
  location            = azurerm_resource_group.terraformRG.location
  allocation_method   = "Static"
    tags = {
        environment = "Atividade 2 ES21 Infra"
    }
}

data "azurerm_public_ip" "terraformPubIpMySQL" {
  name                = azurerm_public_ip.terraformPubIp.name
  resource_group_name = azurerm_resource_group.terraformRG.name
}

resource "azurerm_network_security_group" "terraformSecurityGroup" {
  name                = "securityGroupES21"
  location            = azurerm_resource_group.terraformRG.location
  resource_group_name = azurerm_resource_group.terraformRG.name

  security_rule {
    name                       = "dbSecurityRule"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
        environment = "Atividade 2 ES21 Infra"
    }
}

resource "azurerm_network_interface" "terraformNetworkInterface" {
  name                = "networkInterfaceES21"
  location            = azurerm_resource_group.terraformRG.location
  resource_group_name = azurerm_resource_group.terraformRG.name

  ip_configuration {
    name                          = "ipConfigurationES21"
    subnet_id                     = azurerm_subnet.terraformSN.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraformPubIp.id 
  } 
    tags = {
        environment = "Atividade 2 ES21 Infra"
    }
}

resource "azurerm_network_interface_security_group_association" "terraformInterfaceSecGroupAssociation" {
  network_interface_id      = azurerm_network_interface.terraformNetworkInterface.id
  network_security_group_id = azurerm_network_security_group.terraformSecurityGroup.id
}

resource "azurerm_virtual_machine" "terraformVM" {
  name                  = "vmMySQLTerraformES21"
  location              = azurerm_resource_group.terraformRG.location
  resource_group_name   = azurerm_resource_group.terraformRG.name
  network_interface_ids = [azurerm_network_interface.terraformNetworkInterface.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "DBDysk01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vmmysql"
    admin_username = "adminmysql"
    admin_password = "Adminmysql@123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  } 
    tags = {
        environment = "Atividade 2 ES21 Infra"
    }

}

output "public_ip_address" {
  value = azurerm_public_ip.terraformPubIp.ip_address
}

resource "time_sleep" "wait_30_seconds_db" {
  depends_on = [azurerm_virtual_machine.terraformVM]
  create_duration = "30s"
}

resource "null_resource" "upload_terraformMysql" {
    provisioner "file" {
        connection {
            type = "ssh"
            user = "adminmysql"
            password = "Adminmysql@123"
            host = data.azurerm_public_ip.terraformPubIpMySQL.ip_address
        }
        source = "dbsettings"
        destination = "/home/adminmysql"
    }

    depends_on = [ time_sleep.wait_30_seconds_db ]
}

resource "null_resource" "deploy_terraformMySQL" {
    triggers = {
        order = null_resource.upload_terraformMysql.id
    }
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = "adminmysql"
            password = "Adminmysql@123"
            host = data.azurerm_public_ip.terraformPubIpMySQL.ip_address
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y mysql-server-5.7",
            "sudo mysql < /home/adminmysql/dbsettings/user.sql",
            "sudo cp -f /home/adminmysql/dbsettings/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf",
            "sudo service mysql restart",
            "sleep 20",
        ]
    }
}
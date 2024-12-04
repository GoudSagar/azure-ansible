resource "azurerm_linux_virtual_machine" "devops-vm" {
  name                            = "devops-machine"
  resource_group_name             = azurerm_resource_group.devops_resources.name
  location                        = azurerm_resource_group.devops_resources.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "Adminuser@123"
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.devops-nic.id]
  os_disk {
    name                 = "devops-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

 provisioner "file" {
     source = "/opt/provisioners/index.html"
     destination = "/tmp/index.html"
     connection {
     type = "ssh"
     host = self.public_ip_address
     user = self.admin_username
     password = self.admin_password
   }
 }

 provisioner "local-exec" {
   command = "echo ${azurerm_public_ip.devops-public-ip.ip_address} >> public_ip.txt"
 }


 provisioner "remote-exec" {
   inline = [
     "sudo apt-get update -y",
     "sudo apt-get install apache2 -y",
     "sudo cp -rf /tmp/index.html /var/www/html/index.html",
     "sudo systemctl start apache2",
     "sudo systemctl enable apache2",
    ]     
    connection {
      type = "ssh"
      host = self.public_ip_address
      user = self.admin_username
      password = self.admin_password
    }
  }

}

data "azurerm_public_ip" "devops-public-ip" {
  resource_group_name = azurerm_resource_group.devops_resources.name
  name = azurerm_public_ip.devops-public-ip.name
}

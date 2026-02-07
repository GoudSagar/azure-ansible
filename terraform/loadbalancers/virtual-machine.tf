resource "azurerm_linux_virtual_machine" "devops_vm" {
  count                           = 2
  name                            = "devops-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.devops_resources.name
  location                        = azurerm_resource_group.devops_resources.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "Adminuser@123"
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.devops_nic[count.index].id]
  user_data                       = base64encode(data.template_file.devops-web-server.rendered)

  os_disk {
    name                 = "devops-osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

data "template_file" "devops-web-server" {
  template = file("./azure_data.sh")
}


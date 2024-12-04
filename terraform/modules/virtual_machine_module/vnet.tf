resource "azurerm_virtual_network" "devops_virtual_network" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.devops_resources.name
  location            = azurerm_resource_group.devops_resources.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "devops-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.devops_resources.name
  virtual_network_name = azurerm_virtual_network.devops_virtual_network.name
  address_prefixes     = ["10.1.2.0/26"]
}

resource "azurerm_network_interface" "devops-nic" {
  name                = var.nic_name
  location            = azurerm_resource_group.devops_resources.location
  resource_group_name = azurerm_resource_group.devops_resources.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devops-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops-public-ip.id
  }
}

resource "azurerm_public_ip" "devops-public-ip" {
  name                = var.pip_name
  location            = azurerm_resource_group.devops_resources.location
  resource_group_name = azurerm_resource_group.devops_resources.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}


resource "azurerm_subnet_network_security_group_association" "devops-nsg-association" {
  subnet_id                 = azurerm_subnet.devops-subnet.id
  network_security_group_id = azurerm_network_security_group.devops-nsg.id
}

resource "azurerm_network_interface_security_group_association" "devops_nic_association" {
  network_interface_id      = azurerm_network_interface.devops-nic.id
  network_security_group_id = azurerm_network_security_group.devops-nsg.id
}


resource "azurerm_virtual_network" "devops-network" {
  name                = "devops-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.devops_resources.location
  resource_group_name = azurerm_resource_group.devops_resources.name
}

resource "azurerm_subnet" "devops-subnet" {
  name                 = "devops-mysubnet"
  address_prefixes     = ["10.1.2.0/24"]
  resource_group_name  = azurerm_resource_group.devops_resources.name
  virtual_network_name = azurerm_virtual_network.devops-network.name
}

resource "azurerm_network_interface" "devops-nic" {
  name                = "devops-mynic"
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
  name                = "devops-pip"
  resource_group_name = azurerm_resource_group.devops_resources.name
  location            = azurerm_resource_group.devops_resources.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_security_group" "devops-nsg" {
  name                = "devops-machine-nsg"
  location            = azurerm_resource_group.devops_resources.location
  resource_group_name = azurerm_resource_group.devops_resources.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "devops-nsg-association" {
  subnet_id                 = azurerm_subnet.devops-subnet.id
  network_security_group_id = azurerm_network_security_group.devops-nsg.id
}

resource "azurerm_network_interface_security_group_association" "devops-nic-association" {
  network_interface_id      = azurerm_network_interface.devops-nic.id
  network_security_group_id = azurerm_network_security_group.devops-nsg.id
}


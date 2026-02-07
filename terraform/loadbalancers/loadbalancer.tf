resource "azurerm_lb" "devops_lb" {
  name                = "devops-loadbalancer"
  location            = azurerm_resource_group.devops_resources.location
  resource_group_name = azurerm_resource_group.devops_resources.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lb-frontend"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "devops_lb_backend" {
  name            = "devops-backend-pool"
  loadbalancer_id = azurerm_lb.devops_lb.id
}

resource "azurerm_lb_probe" "devops_lb_probe" {
  name            = "http-probe"
  loadbalancer_id = azurerm_lb.devops_lb.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}


resource "azurerm_lb_rule" "devops_lb_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.devops_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.devops_lb_backend.id]
  probe_id                       = azurerm_lb_probe.devops_lb_probe.id
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "devops-lb-pip"
  location            = azurerm_resource_group.devops_resources.location
  resource_group_name = azurerm_resource_group.devops_resources.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface_backend_address_pool_association" "devops_lb_assoc" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.devops_nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.devops_lb_backend.id
}


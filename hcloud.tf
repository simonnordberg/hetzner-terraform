variable "hcloud_token" {}
variable "location" {
  default = "hel1"
}
resource "hcloud_ssh_key" "default" {
  name       = "hetzner_key"
  public_key = file("~/.ssh/hetzner_ed25519.pub")
}

provider "hcloud" {
  token = var.hcloud_token
}

# Servers
resource "hcloud_server" "photoprism" {
  name         = "photoprism-server"
  image        = "ubuntu-22.04"
  server_type  = "cx11"
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.photoprism_firewall.id]
  labels       = {
    type = "photoprism"
  }
  user_data = file("setup/ubuntu/user_data.yml")
}

resource "hcloud_firewall" "photoprism_firewall" {
  name = "photoprism-firewall"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

variable "hcloud_token" {}
variable "location" {
  default = "hel1"
}
resource "hcloud_ssh_key" "default" {
  name       = "hetzner_key"
  public_key = file("~/.ssh/hetzner_ed25519.pub")
}

provider "hcloud" {
  token = "${var.hcloud_token}"
}

# Servers
resource "hcloud_server" "photoprism" {
  name        = "photoprism-server"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  labels      = {
    type = "photoprism"
  }
  user_data = file("setup/ubuntu/user_data.yml")
}

# Volumes
resource "hcloud_volume" "photoprism_data" {
  name     = "photoprism-data"
  size     = 10
  location = var.location
  format   = "ext4"
}

resource "hcloud_volume" "photoprism_import" {
  name     = "photoprism-import"
  size     = 20
  location = var.location
  format   = "ext4"
}

# Volume attachments
resource "hcloud_volume_attachment" "photoprism_data_attachment" {
  volume_id = hcloud_volume.photoprism_data.id
  server_id = hcloud_server.photoprism.id
  automount = true
}

resource "hcloud_volume_attachment" "photoprism_import_attachment" {
  volume_id = hcloud_volume.photoprism_import.id
  server_id = hcloud_server.photoprism.id
  automount = true
}
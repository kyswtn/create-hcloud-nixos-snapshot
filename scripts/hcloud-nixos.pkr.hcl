packer {
  required_plugins {
    hcloud = {
      # Note that this is not an actual URL, just an arbitrary name.
      source  = "github.com/hetznercloud/hcloud"
      version = "1.6.0"
    }
  }
}

variable "location" {
  type = string
  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "Location is required."
  }
}

variable "server_type" {
  type = string
  validation {
    condition     = length(trimspace(var.server_type)) > 0
    error_message = "Server type is required."
  }
}

variable "ssh_keys" {
  type    = list(string)
  default = []
  validation {
    condition     = length(var.ssh_keys) > 0
    error_message = "At least one SSH key must be provided."
  }
}

variable "host_name" {
  type    = string
  default = "nixos"
}

variable "snapshot_name" {
  type    = string
  default = "nixos-24.11"
}

variable "save_config_to" {
  type = string
}

source "hcloud" "nixos" {
  location        = var.location
  image           = "debian-12"
  server_type     = var.server_type
  rescue          = "linux64"
  snapshot_name   = var.snapshot_name
  snapshot_labels = { name = var.snapshot_name }
  ssh_keys        = []
  ssh_username    = "root"
}

locals {
  tmp_dir = "/tmp/create-hcloud-nixos-snapshot"
}

build {
  sources = ["source.hcloud.nixos"]
  provisioner "shell" {
    inline = ["mkdir -p ${local.tmp_dir}"]
  }
  provisioner "file" {
    source      = "${path.root}/"
    destination = local.tmp_dir
    direction   = "upload"
  }
  provisioner "shell" {
    inline = [
      "chmod +x ${local.tmp_dir}/*.sh",
      "${local.tmp_dir}/prepare-mnt.sh"
    ]
  }
  provisioner "file" {
    source      = "/mnt/etc/nixos/hardware-configuration.nix"
    destination = "${var.save_config_to}/hardware-configuration.nix"
    direction   = "download"
  }
  provisioner "file" {
    content = templatefile(
      "${path.root}/configuration.nix.tpl",
      { host_name = var.host_name, ssh_keys = var.ssh_keys }
    )
    destination = "/mnt/etc/nixos/configuration.nix"
    direction   = "upload"
  }
  provisioner "shell" {
    inline = ["${local.tmp_dir}/install-nixos.sh"]
  }
  provisioner "shell" {
    inline = ["${local.tmp_dir}/cleanup.sh"]
  }
}

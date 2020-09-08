terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
  required_version = ">= 0.13"
}

variable do_token {}
variable pvt_key {}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "ssh_key" {
  name = "terraform_sandbox"
}

resource "digitalocean_droplet" "shd_training" {
  image    = "docker-20-04"
  name     = "docker-1"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /srv/nginx/html",
      "echo 'DAS IST EIN TEST' > /srv/nginx/html/index.html",
      "docker run --name shd_training_nginx -p 80:80 -d -v /srv/nginx/html:/usr/share/nginx/html:ro nginx",
    ]
  }
}

output "server_ip" {
  value = "nginx läuft auf ${digitalocean_droplet.shd_training.ipv4_address}:80"
}

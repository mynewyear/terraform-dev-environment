
provider "google" {
#  credentials = file("~/Documents/keys/terraform-dev-environment-59cdb88bccc4.json")
  credentials = file("~/Documents/keys/terraform-prod-environment-30ea771a4560.json")
  project = "terraform-prod-environment"
#  credentials = "$(terraform.workspace == 'production' ? file('~/Documents/keys/terraform-prod-environment-30ea771a4560.json') : file('~/Documents/keys/terraform-dev-environment-59cdb88bccc4.json')"
#  project = "$(terraform.workspace == 'production' ? 'terraform-prod-environment' : 'terraform-dev-environment')"

  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "vm_instance" {
  name = "terraform-instance"
  machine_type = "f1-micro"
  zone = "us-central1-a"
  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    # A default network is created for all GCP projects
    network =  google_compute_network.terraform_network.self_link
    # use ephemeral IP
    access_config {}
  }
  metadata_startup_script = <<-EOF
  #!/bin/bash
  sudo su
  apt -y install apache2
  echo "<p> Hello World! </p>" > /var/www/html/index.html
  EOF


}

resource "google_compute_firewall" "terraform_firewall" {
  name    = "test-firewall"
  network = google_compute_network.terraform_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  target_tags = ["web"]
}

resource "google_compute_network" "terraform_network" {
  name = "test-network"
  auto_create_subnetworks = "true"
}

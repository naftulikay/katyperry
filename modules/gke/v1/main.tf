variable "name" { }
variable "description" { }
variable "region" { }
variable "network" { }
variable "subnetwork" { }
variable "node_count" { }
variable "disk_size_gb" { }
variable "machine_type" { }

resource "google_container_cluster" "default" {
  name = "${var.name}"
  description = "${var.description}"
  initial_node_count = 1
  remove_default_node_pool = true

  region = "${var.region}"

  min_master_version = "1.11.2-gke.18"
  node_version = "1.11.2-gke.18"

  network = "${var.network}"
  subnetwork = "${var.subnetwork}"

  ip_allocation_policy {
    cluster_secondary_range_name = "kubernetes"
    services_secondary_range_name = "management"
  }
}

resource "google_container_node_pool" "default" {
  name = "default"
  cluster = "${google_container_cluster.default.name}"
  node_count = "${var.node_count}"

  region = "${var.region}"

  node_config {
    disk_size_gb = "${var.disk_size_gb}"
    machine_type = "${var.machine_type}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

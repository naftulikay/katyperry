provider "google" {
  region = "us-west1"
  project = "naftuli-test"
}

data "google_client_config" "default" {}

resource "google_compute_network" "default" {
  name = "gke-test"
  routing_mode = "REGIONAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name = "gke-test-public"
  ip_cidr_range = "10.0.0.0/19"
  network = "${google_compute_network.default.self_link}"
  private_ip_google_access = true

  secondary_ip_range {
    range_name= "kubernetes"
    ip_cidr_range = "10.0.32.0/19"
  }

  secondary_ip_range {
    range_name = "management"
    ip_cidr_range = "10.0.64.0/19"
  }
}

resource "google_container_cluster" "default" {
  name= "gke-test-1"
  description = "GKE Testing Cluster"
  region = "${data.google_client_config.default.region}"
  initial_node_count = 1
  remove_default_node_pool = true

  network = "${google_compute_network.default.self_link}"
  subnetwork = "${google_compute_subnetwork.default.self_link}"

  ip_allocation_policy {
    cluster_secondary_range_name = "kubernetes"
    services_secondary_range_name = "management"
  }
}

resource "google_container_node_pool" "default" {
  name = "default"
  region = "${data.google_client_config.default.region}"
  cluster = "${google_container_cluster.default.name}"
  node_count = 2

  node_config {
    disk_size_gb = 128
    machine_type = "n1-standard-4"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

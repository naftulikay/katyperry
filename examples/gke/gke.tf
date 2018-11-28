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

module "gke" {
  source = "../../modules/gke/v1"

  name = "gke-test-1"
  description = "GKE Testing Cluster"

  region = "us-central1"

  network = "${google_compute_network.default.self_link}"
  subnetwork = "${google_compute_subnetwork.default.self_link}"

  node_count = 2

  disk_size_gb = 128
  machine_type = "n1-standard-4"
}

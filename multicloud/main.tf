provider "google" {
  project = var.project
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name               = "gke-cluster"
  location           = var.region
  initial_node_count = 3

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

output "kubernetes_cluster_name" {
  value = google_container_cluster.primary.name
}
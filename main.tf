provider "google" {
  project     = "tf-eks"
  region      = "us-central1"
  
}

data "google_client_config" "default" {}

# Service account for node configuration
resource "google_service_account" "default" {
  account_id   = "argo-sa"
  display_name = "Argo SA"
}

#Small cluster for purposes of Argo installation
resource "google_container_cluster" "my_cluster" {
  name               = "argo-cluster-fun"
  location           = "us-central1-c"  
  initial_node_count = 1
  remove_default_node_pool = true
  # Disable deletion protection
  deletion_protection = false
}




resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "primary"
  cluster    = google_container_cluster.my_cluster.id
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}




provider "kubernetes" {
    host                   = "https://${google_container_cluster.my_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
resource "kubernetes_namespace" "argo-ns" {
  metadata {
    name = "argocd"
  }
}


# The awful work-around
# So the kubernetes api is not ready to service helm below
resource "time_sleep" "wait_gke_cluster" {
  depends_on = [kubernetes_namespace.argo-ns]

  create_duration =  var.wait_for_gke_cluster
}

resource "helm_release" "argocd" {
  
  depends_on = [ google_container_cluster.my_cluster ]
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  name       = "argocd"
  namespace  = "argocd"
  timeout = 6000
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}

data "kubernetes_secret" "initial_secret" {
    depends_on = [ helm_release.argocd ]
    metadata {
        name = "argocd-initial-admin-secret"
        namespace = "argocd"
    }
}
data "kubernetes_service" "argocd_server" {
  depends_on = [ helm_release.argocd ]
  metadata {
    #This is hard coded but may vary for helm changes
    name = "argocd-server"
    namespace = "argocd"
  }
}
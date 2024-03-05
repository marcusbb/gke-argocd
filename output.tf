
output "argo_secret_output" {
    value = data.kubernetes_secret.initial_secret
    sensitive = true
}

output "argo_service_data" {
    value = data.kubernetes_service.argocd_server.spec
}
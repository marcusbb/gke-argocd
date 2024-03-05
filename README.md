# Deploying ArgoCD on Kubernetes GKE

Terraform to deploy a single node GKE cluster with ArgoCD.

You can read the code in [main](main.tf) which gives the most in depth explanation.

Argo does deployment management on Kubernetes!  So this repository gives you the bootstrapping capabilities to manage your Kubernetes cluster once set up.

Remember to source you GCP credentials appropriately.

There is a terrible workaround on [line 58](main.tf) which basically a timed wait condition for the GKE cluster to become ready.  This is documented here
https://github.com/hashicorp/terraform-provider-google/issues/7823

The default time (5 min) after cluster creation should provide sufficient time for the api services to come up.  Subsequent invocations you can set the timeout to be small or zero
```
terraform plan/apply -var wait_for_gke_cluster=1s
```
Note that the output should include information on argo's external load balancer IP, however I've found that this is not populated in TF output as it's part of the status of kubernetes service, not the spec.
```
argo_service_data = tolist([
  {
    "allocate_load_balancer_node_ports" = true
    "cluster_ip" = "10.84.4.130"
    "cluster_ips" = tolist([
      "10.84.4.130",
    ])
    "external_ips" = toset([])
    ...
])
```
To access the IP
```
kubectl -n argocd get service argocd-server -o json | jq -r '.status.loadBalancer.ingress[0].ip'
```
Your initial credentials are username: admin
Password can be sourced
```
tf output -json argo_secret_output | jq .data.password
```

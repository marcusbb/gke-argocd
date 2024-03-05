## Notes 

Why not Terraform or the Kubernetes provider from Terraform?  
Terraform is a great general purpuse provisioner for infrastructure.  In particular infrastructure in cloud. With the wide adoption as the standard IaC platform it makes sense to codify your infrastructure using terraform.

But Terraform breaks down when managing Kubernetes deployments.  Deployment management is typically custom built as well defined portable yaml manifests.  Templating for such manifests can be accomplished in Terraform but it's awkward and not native to the platform. 
The point is that you aren't modifying TF code when deploying a kubernetes application.  You're building a set of kubernetes resources whose state could be all defined in terraform, but it's really awkward, and for novices would be difficult if not impossible to navigate your kuberneetes resources in HCL.
 
Helm to the rescue!  Helm is built to be the package manager for Kubernetes.  There isn't much you can't install on Kubernetes that isn't packaged as a Helm chart.  
But you can install Helm charts with helm_release?  Absolutely!  However terraform code is pretty dumb when it comes to managing the state of helm installations.
output "argocd_namespace" {
  value       = helm_release.argocd.namespace
  description = "The Kubernetes namespace where Argo CD is deployed"
}

output "argocd_admin_password_command" {
  value       = "kubectl -n ${helm_release.argocd.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  description = "Command that prints the initial password of the Argo CD admin user"
}

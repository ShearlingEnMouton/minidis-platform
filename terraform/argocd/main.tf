resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "10.18.0"

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = helm_release.argocd.namespace
  version    = "2.0.8"

  values = [
    file("${path.module}/apps-values.yaml")
  ]

  depends_on = [helm_release.argocd]
}

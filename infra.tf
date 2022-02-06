resource "kubernetes_namespace" "danart" {
  metadata {
    name = "daniela-art"
  }
}

variable "service_port" {
  type = number
}

resource "kubernetes_deployment" "danart" {
  metadata {
    name      = "danart-deployment"
    namespace = kubernetes_namespace.danart.metadata.0.name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "danart"
      }
    }

    template {
      metadata {
        labels = {
          app = "danart"
        }
      }
      spec {
        container {
          name  = "danart"
          image = "jdevries3133/danart:0.0.1"
        }
      }
    }
  }
}

resource "kubernetes_service" "danart" {
  metadata {
    name      = "danart-service"
    namespace = kubernetes_namespace.danart.metadata.0.name
  }

  spec {
    selector = {
      app = kubernetes_deployment.danart.spec.0.template.0.metadata.0.labels.app
    }
    type             = "LoadBalancer"
    session_affinity = "ClientIP"
    port {
      port        = var.service_port
      target_port = 80
    }
  }
}

terraform {

  backend "s3" {
    bucket = "my-sites-terraform-remote-state"
    key    = "daniela_art"
    region = "us-east-2"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.8.0"
    }

  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "danart" {
  metadata {
    name = "daniela-art"
  }
}

data "external" "git_describe" {
  program = ["sh", "scripts/git_describe.sh"]
}

resource "kubernetes_deployment" "danart" {
  metadata {
    name      = "danart-deployment"
    namespace = kubernetes_namespace.danart.metadata[0].name
  }

  spec {
    replicas = 1

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
          image = "jdevries3133/danart:${data.external.git_describe.result.output}"
        }
      }
    }
  }
}

resource "kubernetes_service" "danart" {
  metadata {
    name      = "danart-service"
    namespace = kubernetes_namespace.danart.metadata[0].name
  }

  spec {
    selector = {
      app = "danart"
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "danart_ingress" {
  metadata {
    name      = "danart-ingress"
    namespace = kubernetes_namespace.danart.metadata[0].name
  }

  spec {
    ingress_class_name = "public"
    tls {
      hosts = ["danart.us"]
    }
    rule {
      host = "danart.us"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.danart.metadata.0.name
              port {
                number = kubernetes_service.danart.spec.0.port.0.port
              }
            }
          }
        }
      }
    }
  }

}

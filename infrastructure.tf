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
  config_path = "~/.kube/prod_config"
}

resource "kubernetes_namespace" "danart" {
  metadata {
    name = "daniela-art"
  }
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
          image = "jdevries3133/danart:0.0.3"
        }
      }
    }
  }
}

resource "kubernetes_service" "danart" {
  metadata {
    name      = "danart-service"
    namespace = "daniela-art"
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
    name = "danart-ingress"
    namespace = "daniela-art"
  }

  spec {
    ingress_class_name = "public"
    rule {
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "danart-service"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }

}

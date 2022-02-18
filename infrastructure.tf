terraform {

  backend "s3" {
    bucket = "my-sites-terraform-remote-state"
    key    = "daniela_art"
    region = "us-east-2"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
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

variable "service_port" {
  type = number
}

resource "kubernetes_deployment" "danart" {
  metadata {
    name      = "danart-deployment"
    namespace = kubernetes_namespace.danart.metadata.0.name
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
          image = "jdevries3133/danart:0.0.2"
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

// TODO: ingress controller config
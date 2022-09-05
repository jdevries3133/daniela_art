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


module "container-deployment" {
  source  = "jdevries3133/container-deployment/kubernetes"
  version = "0.3.0"

  app_name = "danart"
  container = "jdevries3133/danart:${data.external.git_describe.result.output}"
  domain = "danart.us"
}

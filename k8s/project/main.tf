terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment_v1" "nginx_app" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = "nginx"
          image = var.container_image

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nginx_service" {
  metadata {
    name      = "${var.app_name}-svc"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

variable "namespace" {
  type    = string
  default = "sre-apps"
}

variable "app_name" {
  type    = string
  default = "nginx-sre"
}

variable "container_image" {
  type    = string
  default = "nginx:latest"
}

variable "replicas" {
  type    = number
  default = 2
}

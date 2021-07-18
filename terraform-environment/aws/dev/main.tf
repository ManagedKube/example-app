terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.37.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  backend "remote" {
    organization = "managedkube"

    workspaces {
      name = "kubernetes-ops-dev-example-app"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "eks" {
  backend = "remote"
  config = {
    organization = "managedkube"
    workspaces = {
      name = "kubernetes-ops-dev-20-eks"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.environment_name]
      command     = "aws"
    }
  }
}

# Helm values file templating
data "template_file" "helm_values" {
  template = file("${path.module}/helm_values.yaml")

  # Parameters you want to pass into the helm_values.yaml.tpl file to be templated
  vars = {
    fullnameOverride  = "${var.namespace}-worker"
    namespace         = var.namespace
    replica_count     = var.replica_count
    docker_repository = var.docker_repository
    docker_tag        = var.docker_tag
    requests_memory   = var.requests_memory
  }
}

module "app" {
  source = "github.com/ManagedKube/kubernetes-ops//terraform-modules/aws/helm/helm_generic?ref=v1.0.9"

  # this is the helm repo add URL
  repository = "https://helm-charts.managedkube.com"
  # This is the helm repo add name
  official_chart_name = "standard-application"
  # This is what you want to name the chart when deploying
  user_chart_name = "${var.namespace}-worker"
  # The helm chart version you want to use
  helm_version = "1.0.11"
  # The namespace you want to install the chart into - it will create the namespace if it doesnt exist
  namespace = var.namespace
  # The helm chart values file
  helm_values = data.template_file.helm_values.rendered

  depends_on = [
    var.eks
  ]
}

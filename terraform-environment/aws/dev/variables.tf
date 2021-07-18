variable "namespace" {}
variable "eks" {}
variable "environment_name" {}
variable "replica_count" {
  default = 1
}
variable "requests_memory" {
  default = "1Gi"
}
variable "worker_repository" {}
variable "worker_tag" {}
variable "tags" {
  type = map(any)
  default = {
    ops_env              = "dev"
    ops_managed_by       = "terraform",
    ops_source_repo      = "kubernetes-ops",
    ops_source_repo_path = "terraform-environments/aws/dev",
    ops_owners           = "example-app",
  }
}

terraform {
  # Bootstrap creates this bucket. Backend values cannot use input variables;
  # configure namespace, region, bucket and key via terraform init -backend-config.
  backend "oci" {}
}

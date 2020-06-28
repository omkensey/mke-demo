provider "aws" {
  # Change your default region here
  region = "us-east-2"
}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.2.0"

  providers = {
    aws = "aws"
  }

  cluster_name        = "mke-demo"
  ssh_public_key_file = "/home/kensey/.ssh/id_rsa.pub"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = 1
  num_private_agents = 4
  num_public_agents  = 0

  dcos_version = "2.1.0"

  # dcos_variant              = "ee"
  # dcos_license_key_contents = "${file("./license.txt")}"
  # Make sure to set your credentials if you do not want the default EE
  # dcos_superuser_username      = "superuser-name"
  # dcos_superuser_password_hash = "${file("./dcos_superuser_password_hash.sha512")}"
  dcos_variant = "open"

  dcos_instance_os             = "centos_7.5"
  bootstrap_instance_type      = "m5.large"
  masters_instance_type        = "m5.2xlarge"
  private_agents_instance_type = "m5.xlarge"
  public_agents_instance_type  = "m5.xlarge"
}

output "masters-ips" {
  value = "${module.dcos.masters-ips}"
}

output "cluster-address" {
  value = "${module.dcos.masters-loadbalancer}"
}

output "public-agents-loadbalancer" {
  value = "${module.dcos.public-agents-loadbalancer}"
}


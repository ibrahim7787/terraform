module "vpc_nat_vm" {
  source = "terraform-aws-modules/vpc/aws"

  # VPC
  name = "myvpc"
  cidr = "10.0.0.0/16"

  # Subnets
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]

  # Enable Cloud NAT
  enable_nat_gateway = true

  # Enable NATing for Private Subnet
  enable_private_subnet_nating = true

  # Deploy Virtual Machine on Private Subnet
  deploy_vm_in_private_subnet = true

  # Check Internet Access
  check_internet_access = true

  # Check IP
  check_my_ip = true

}

resource "aws_key_pair" "eks" {
  key_name   = "eks"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ONJth+DzeXbU3oGATxjVmoRjPepdl7sBuPzzQT2Nc sivak@BOOK-I6CR3LQ85Q"
  #public_key = file("~/.ssh/eks.pub")   # provide your own key here
  public_key = file("D:/Personal/DevOps/JoinDevOps-SivaKumarReddy/Practice/test-keypair-3.pub")
  # ~ means windows home directory
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  #cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr
  cluster_name    = "${var.project_name}-${var.environment}"        # expense-dev
  
  #cluster_version = "1.29"   # we can give the 1.29 version before the eks cluster upgrade
  cluster_version = "1.30"    # we can give 1.30 as the version during the upgrade
  #cluster_version = "1.31"


  cluster_endpoint_public_access = true  # it should be false in PROD environments
  # Indicates whether or not the Amazon EKS public API server endpoint is enabled

  vpc_id                   = local.vpc_id
  subnet_ids               = split(",", local.private_subnet_ids)       # we should not expose eks node to the public, so use private subnets.
  control_plane_subnet_ids = split(",", local.private_subnet_ids)

  create_cluster_security_group = false
  cluster_security_group_id     = local.cluster_sg_id       #generally cluster will create default sg, but we customized created our own sg.

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id     #generally cluster will create default sg, but we customized created our own sg.

  # the user which you used to create cluster will get admin access
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    ## for the 1st run we have run with blue deployment
    ## once blue deployment is up and running then we will comment the blue and uncomment green deployment and run the deployment for green -2nd run deployment
    blue = {
      min_size      = 2
      max_size      = 10
      desired_size  = 2
      #capacity_type = "SPOT"         ##usually for practice we can use SPOT instances.
      capacity_type  = "ON_DEMAND"    
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
      # EKS takes AWS Linux 2 as it's OS to the nodes
      key_name = aws_key_pair.eks.key_name
    }

    ## while 1st run we will comment the green deployment
    ## for the 2nd run we have run with green deployment
    # green = {
    #   min_size      = 2
    #   max_size      = 10
    #   desired_size  = 2
    #   #capacity_type = "SPOT"         ##usually for practice we can use SPOT instances.
    #   capacity_type  = "ON_DEMAND"
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
    #     ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    #   # EKS takes AWS Linux 2 as it's OS to the nodes
    #   key_name = aws_key_pair.eks.key_name
    # }
  }

  tags = var.common_tags
}
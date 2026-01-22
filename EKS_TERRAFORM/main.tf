# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get public subnets in supported AZs for control plane
data "aws_subnets" "eks_control_plane" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b"] # Use at least two supported AZs
  }
}

# Optional: get all public subnets for worker nodes
data "aws_subnets" "eks_nodes" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Cluster provision
resource "aws_eks_cluster" "example" {
  name     = "EKS_CLUSTER"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = data.aws_subnets.eks_control_plane.ids
    endpoint_private_access = false
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
  ]
}

# Node group
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "Node-cloud"
  node_role_arn   = aws_iam_role.example1.arn
  subnet_ids      = data.aws_subnets.eks_nodes.ids

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 3
  }

  instance_types = ["t3.small"]

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

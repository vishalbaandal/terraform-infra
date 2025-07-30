data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-IG"
    Environment = var.env_suffix
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_cidr_block)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_cidr_block, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(var.public_cidr_block)]
  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-Public-Subnet-${count.index}"
    Environment = var.env_suffix
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_block)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_cidr_block, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index % length(var.private_cidr_block)]
  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-Private-Subnet-${count.index}"
    Environment = var.env_suffix
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-Public-RT"
    Environment = var.env_suffix
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route  = []
  #   route {
  #     cidr_block     = "0.0.0.0/0"
  #     nat_gateway_id = aws_nat_gateway.natgw.id
  #   }
  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-Private-RT"
    Environment = var.env_suffix
  }
}

resource "aws_route_table_association" "private_rt_association" {
  count          = length(aws_subnet.private_subnet[*].id)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-VPC"
    Environment = var.env_suffix
  }
}

resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.vpc.arn
  log_destination = aws_cloudwatch_log_group.vpc.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.env_suffix}-VPC-Flow-Log"
  }
}

resource "aws_cloudwatch_log_group" "vpc" {
  name              = "${var.project_name}-${var.env_suffix}-VPC-Flow-Logs"
  retention_in_days = 7
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc" {
  name               = "${var.project_name}-${var.env_suffix}-VPC-Flow-Log-Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "vpc" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "vpc" {
  name   = "${var.project_name}-${var.env_suffix}-VPC-Flow-Log-Policy"
  role   = aws_iam_role.vpc.id
  policy = data.aws_iam_policy_document.vpc.json
}


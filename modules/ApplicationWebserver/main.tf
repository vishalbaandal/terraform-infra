# Fetch AMI
data "aws_ami" "instance_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name}*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["099720109477"] # Canonical
}

# Create Security Group For EC2
#tfsec:ignore:aws-ec2-no-public-egress-sgr
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
resource "aws_security_group" "application_sg" {
  name        = "${var.project_name}-${var.env_suffix}-Application-SG"
  description = "Application - Security Group"
  vpc_id      = var.vpc_id

  # Inbound Traffic Rule
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"]
    description = "SSH Traffic"
  }

  dynamic "ingress" {
    for_each = var.ingress_port
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Outbound Traffic Rule
  dynamic "egress" {
    for_each = length(var.egress_port) > 0 ? toset(var.egress_port) : [0]

    content {
      from_port        = egress.value == 0 ? 0 : egress.value
      to_port          = egress.value == 0 ? 0 : egress.value
      protocol         = egress.value == 0 ? "-1" : "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = egress.value == 0 ? "Allow all Traffic" : ""
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-Application-SG"
    Environment = var.env_suffix
  }
}

# Create EIP For EC2
resource "aws_eip" "application_eip" {
  count = var.ec2_count
  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-EIP-${count.index + 1}"
    Environment = var.env_suffix
  }
}

# Create OpenSSH Key
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create SSH Key with the help of OpenSSH Key
resource "aws_key_pair" "keypair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.key.private_key_pem}' > ./${var.key_pair_name}.pem"
  }
  tags = {
    Name        = "${var.project_name}-Key"
    Environment = var.env_suffix
  }
}

data "aws_iam_policy_document" "ec2_iam_policy" {
  source_policy_documents = [file("${path.module}/iam-policy.json")]
}

# Create IAM Policy For EC2 Role
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.project_name}-${var.env_suffix}-EC2-Policy"
  description = "S3 SecretManager and CloudWatch Access Policy For EC2"
  policy      = data.aws_iam_policy_document.ec2_iam_policy.json

  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-EC2-Policy"
    Environment = var.env_suffix
  }
}

# Create IAM Role For EC2
resource "aws_iam_role" "ec2_s3_sm_access_role" {
  name = "${var.project_name}-${var.env_suffix}-EC2-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-EC2-Role"
    Environment = var.env_suffix
  }
}

# Attached IAM Policy to IAM Role
resource "aws_iam_policy_attachment" "ec2_policy_attached" {
  name       = "${var.project_name}-${var.env_suffix}-EC2-Policy-Attachment"
  roles      = [aws_iam_role.ec2_s3_sm_access_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.env_suffix}-EC2-Profile"
  role = aws_iam_role.ec2_s3_sm_access_role.name
}

resource "aws_instance" "web" {
  count                       = var.ec2_count
  ami                         = data.aws_ami.instance_ami.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.keypair.key_name
  vpc_security_group_ids      = [aws_security_group.application_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  monitoring                  = var.ec2_monitoring
  subnet_id                   = var.ec2_subnet_id
  associate_public_ip_address = true
  
  # User data script to install and configure nginx
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              
              # Start and enable nginx
              systemctl start nginx
              systemctl enable nginx
              
              # Create a custom index page
              cat > /var/www/html/index.html << 'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Welcome to ${var.project_name}</title>
                  <style>
                      body { font-family: Arial, sans-serif; margin: 40px; }
                      .header { color: #333; text-align: center; }
                      .info { background: #f4f4f4; padding: 20px; border-radius: 5px; }
                  </style>
              </head>
              <body>
                  <h1 class="header">Welcome to ${var.project_name}</h1>
                  <div class="info">
                      <h2>Server Information</h2>
                      <p><strong>Environment:</strong> ${var.env_suffix}</p>
                      <p><strong>Server:</strong> $(hostname)</p>
                      <p><strong>Nginx:</strong> Successfully installed and running</p>
                  </div>
              </body>
              </html>
              HTML
              
              # Restart nginx to ensure everything is working
              systemctl restart nginx
              
              # Log the completion
              echo "$(date): Nginx installation and configuration completed" >> /var/log/user-data.log
              EOF
  )

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    encrypted             = true
    volume_type           = var.ebs_volume_type
    volume_size           = var.ebs_volume_size
    delete_on_termination = true
    tags = {
      Name        = "${var.project_name}-${var.env_suffix}-EBS-Volume"
      Environment = var.env_suffix
    }
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.key_pair_name}.pem")
    host        = self.public_ip
  }

  tags = {
    Name        = "${var.project_name}-${var.env_suffix}"
    Environment = var.env_suffix
  }

  depends_on = [
    aws_security_group.application_sg,
    aws_key_pair.keypair,
    aws_eip.application_eip
  ]
}

# Attach EIP to EC2 Instance
resource "aws_eip_association" "application_eip_assoc" {
  count         = var.ec2_count
  instance_id   = aws_instance.web[count.index].id
  allocation_id = aws_eip.application_eip[count.index].id

  depends_on = [
    aws_instance.web,
    aws_eip.application_eip
  ]
}

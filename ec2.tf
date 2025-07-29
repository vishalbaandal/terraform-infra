resource "aws_instance" "web" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = data.template_file.nginx.rendered

  tags = merge(var.tags, { Name = "nginx-instance-${count.index + 1}" })
}

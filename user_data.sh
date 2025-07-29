data "template_file" "nginx" {
  template = file("${path.module}/user_data.sh")
}

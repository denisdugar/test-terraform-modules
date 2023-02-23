data "template_file" "user_data" {
  template = "${file(var.user_data)}"
  vars = var.data_vars
}
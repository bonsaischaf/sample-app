# variables.tf ist die saubere aber nicht notwendige Bezeichnung. *.tf wird ausgewertet.
# Es können auch fremdmodule einbezogen werden, z.B. aus einem vcs.

# count wird mit var.sample-app-count initialisiert. count ist ein Terraform-Keyword, welches
# beschreibt, wie oft eine Resource angelegt wird.

# Referenziere über "${var.sample-app-count}"
variable "sample-app-count" {
  default = 2
}


variable "my-resource-group" {
  default = "cschaffe-test"
}

variable "user" {}

variable "password" {}

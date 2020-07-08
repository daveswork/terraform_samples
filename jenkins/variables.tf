variable "public_key_path" {
    type    = string
    default  = "./pub_key.pub"
}

variable "user_data_file" {
    type    = string
    default = "./install_jenkins.sh"
}

variable "inbound_ssh" {
    type    = list
    default = ["0.0.0.0/0"]
}

variable "inbound_jenkins" {
    type    = list
    default = ["0.0.0.0/0"]
}

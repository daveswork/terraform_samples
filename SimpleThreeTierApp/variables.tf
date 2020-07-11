variable "public_key_path" {
    type    = string
    default  = "./pub_key.pub"
}

variable "user_data_file" {
    type    = string
    default = "./install_httpd.sh"
}

variable "inbound_ssh" {
    type    = list
    default = ["0.0.0.0/0"]
}

variable "inbound_http" {
    type    = list
    default = ["0.0.0.0/0"]
}

variable "all_networks"{
    type    = list
    default = ["0.0.0.0/0"]
}

variable "az" {
    type    = list
    default = ["us-east-1a", "us-east-1b"]
}
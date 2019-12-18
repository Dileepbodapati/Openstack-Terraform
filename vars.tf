variable "image" {
  default = "Ubuntu 16.04"
}

variable "flavor" {
  default = "m1.small"
}

variable "ssh_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "pool" {
  default = "public"
}

variable "instance_count" {
  default = 10
}

variable "instance_tags" {
 type = "list"
 default =  [ "Test1", "Test2" , "Test3" , "Test4" , "Test5" , "Test6" , "Test7" , "Test8" , "Test9" , "Test10" ]
}

variable "user_name" {
  default = 10
}

variable "tenant_name" {
  default = 10
}

variable "pwd" {
  default = 10
}

variable "region" {
  default = 10
}

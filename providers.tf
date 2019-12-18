provider "openstack" {
  user_name   = "${var.user_name}"
  tenant_name = "${var.tenant_name}"
  password    = "${var.pwd}"
  auth_url    = "http://myauthurl:5000/v2.0"
  region      = "${var.region}"
}

data "openstack_networking_network_v2" "Devops" {
  name = "${var.pool}"
}
# Creating a secret key(private key)

resource "openstack_compute_keypair_v2" "Devops" {
  name       = "Devops"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

#creating Network

resource "openstack_networking_network_v2" "Devops" {
  name           = "Devops"
  admin_state_up = "true"
}

#Creating subnets

resource "openstack_networking_subnet_v2" "Devops" {
  name            = "Devops"
  network_id      = "${openstack_networking_network_v2.Devops.id}"
  cidr            = "10.0.0.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

#Creating Router

resource "openstack_networking_router_v2" "Devops" {
  name                = "Devops"
  admin_state_up      = "true"
  external_network_id = "${data.openstack_networking_network_v2.Devops.id}"
}

#Creating a route to internet GW

resource "openstack_networking_router_interface_v2" "Devops" {
  router_id = "${openstack_networking_router_v2.Devops.id}"
  subnet_id = "${openstack_networking_subnet_v2.Devops.id}"
}

#Creating a security Group
resource "openstack_networking_secgroup_v2" "Devops" {
  name        = "Devops"
}

#Creating security group inbound rules for ssh port
resource "openstack_networking_secgroup_rule_v2" "Devops_22" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.Devops.id}"
}

#Creating security group inbound rules for http port
resource "openstack_networking_secgroup_rule_v2" "Devops_80" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.Devops.id}"
}

#Creating security group rules for outbound traffic
resource "openstack_networking_secgroup_rule_v2" "Devops" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.Devops.id}"
}

#Creating floating pool
resource "openstack_networking_floatingip_v2" "Devops" {
  pool = "${var.pool}"
}

#Creating a compute NOVA instance
resource "openstack_compute_instance_v2" "Devops" {
  count           = "${var.instance_count}"
  name            = "${element(var.instance_tags, count.index)}"
  image_name      = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${openstack_compute_keypair_v2.Devops.name}"
  security_groups = ["${openstack_networking_secgroup_v2.Devops.name}"]

  network {
    uuid = "${openstack_networking_network_v2.Devops.id}"
  }
}

#Assigning security group to NOVA instance
resource "openstack_compute_floatingip_associate_v2" "Devops" {
  floating_ip = "${openstack_networking_floatingip_v2.Devops.address}"
  instance_id = "${openstack_compute_instance_v2.Devops.id}"

#Bootstrapping the script  to install Docker
  provisioner "remote-exec" {
    connection {
      host        = "${openstack_networking_floatingip_v2.Devops.address}"
      user        = "${var.ssh_user_name}"
      private_key = "${file(var.ssh_key_file)}"
    }

    inline = [
      "sudo apt-get -y update",
      "sudo curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
    ]
  }
}

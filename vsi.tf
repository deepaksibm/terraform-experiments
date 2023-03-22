
resource "ibm_is_vpc" "vpc" {
    name = "test-vpc"
}

resource "ibm_is_subnet" "subnet" {
    name = "test-subnet"
    vpc = ibm_is_vpc.vpc.id
    zone = "us-south-2"
    total_ipv4_address_count = 16
}
resource "ibm_is_instance" "instance" {
    name = "test-instance"
    image = data.ibm_is_image.this.id
    profile = "bx2-2x8"
    metadata_service_enabled = true
    default_trusted_profile_target = "Profile-XXXXXXXX-aXXa-4XX1-8XX2-0XXXXXXXXXX5"
    primary_network_interface {
        subnet = ibm_is_subnet.testacc_subnet.id
        security_groups = [ibm_is_vpc.vpc.default_security_group]
    }
    user_data = data.template_cloudinit_config.config.rendered
    vpc = ibm_is_vpc.vpc.id
    zone = ibm_is_subnet.subnet.zone
    keys = [data.ibm_is_ssh_key.sshkey.id]
}

data "template_cloudinit_config" "config" {
  gzip = false
  base64_encode = false

  part {
      filename = "init-shellscript"
      content_type = "text/x-shellscript"
      content = templatefile("cloudinit_completion_check.sh", { trustedprofile = "Profile-XXXXX" })
  }
}
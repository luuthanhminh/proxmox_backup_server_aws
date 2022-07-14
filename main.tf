provider "aws" {
  region  = "ap-southeast-1"
  profile = "ops_tf"
}

### Resources

resource "aws_security_group" "allow_proxmox_remote" {
  name_prefix = "proxmox-remote"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port = 8007
    to_port   = 8007
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = local.tags
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.node_name

  ami                         = data.aws_ami.debian-10.id
  instance_type               = "t4g.small"
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.allow_proxmox_remote.id]
  subnet_id                   = data.aws_subnet.default.id
  associate_public_ip_address = true

  user_data_base64 = base64encode(
    templatefile("${path.root}/userdata.tpl", {})
  )

  tags = merge(local.tags, {
    Name = var.node_name
  })
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.id
  instance_id = module.ec2_instance.id
}

resource "aws_ebs_volume" "this" {
  availability_zone = data.aws_subnet.default.availability_zone
  size              = 30

  tags = local.tags
}

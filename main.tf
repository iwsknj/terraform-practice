provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.region}"
}

# 作成したキーペアを格納するファイルを指定。
# 存在しないディレクトリを指定した場合は新規にディレクトリを作成してくれる
locals {
  public_key_file  = "./.key_pair/${var.key_name}.id_rsa.pub"
  private_key_file = "./.key_pair/${var.key_name}.id_rsa"
}

# privateキーのアルゴリズム設定
resource "tls_private_key" "test" {
	algorithm = "RSA"
  rsa_bits  = 4096
}

# local_fileのリソースを指定するとterraformを実行するディレクトリ内でファイル作成やコマンド実行が出来る。
resource "local_file" "private_key_pem" {
	filename = "${local.private_key_file}"
	content = "${tls_private_key.test.private_key_pem}"
	provisioner "local-exec" {
		command = "chmod 600 ${local.private_key_file}"
	}
}

resource "local_file" "public_key_openssh" {
  filename = "${local.public_key_file}"
  content  = "${tls_private_key.test.public_key_openssh}"
  provisioner "local-exec" {
    command = "chmod 600 ${local.public_key_file}"
  }
}

resource "aws_key_pair" "key_pair" {
	key_name = "${var.key_name}"
	public_key = "${tls_private_key.test.public_key_openssh}"
}

resource "aws_vpc" "test_vpc" {
	cidr_block = "10.0.0.0/16"
	enable_dns_support = "true"
	enable_dns_hostnames = "false"
	tags = {
		Name = "test_vpc"
	}
}

resource "aws_internet_gateway" "test_gw" {
	vpc_id = "${aws_vpc.test_vpc.id}"
	tags = {
		Name = "test_gw"
	}
}

resource "aws_subnet" "public-a" {
	vpc_id = "${aws_vpc.test_vpc.id}"
	cidr_block = "10.0.0.0/24"
	availability_zone = "ap-northeast-1a"
	tags = {
		Name = "test_subnet"
	}
}

resource "aws_route_table" "public-route" {
	vpc_id = "${aws_vpc.test_vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.test_gw.id}"
	}
}

resource "aws_route_table_association" "public-a" {
	subnet_id = "${aws_subnet.public-a.id}"
	route_table_id = "${aws_route_table.public-route.id}"
}

resource "aws_security_group" "test" {
	name = "admin"
	description = "Allow SSH inbound traffic"
	vpc_id = "${aws_vpc.test_vpc.id}"

	# インバウンドルール（ssh接続用）
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["${var.home_ip_address}"]
	}

	# インバウンドルール(pingコマンド用)
	ingress {
		from_port = -1
		to_port = -1
		protocol = "icmp"
		cidr_blocks = ["${var.home_ip_address}"]
	}

	# アウトバウンドルール
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_instance" "test" {
	ami = "ami-0a3d21ec6281df8cb"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.key_pair.id}"
	vpc_security_group_ids = [
		"${aws_security_group.test.id}"
	]
	subnet_id = "${aws_subnet.public-a.id}"
	associate_public_ip_address = "true"
	root_block_device {
		volume_type = "gp2"
		volume_size = "20"
	}
	ebs_block_device {
		device_name = "/dev/sdf"
		volume_type = "gp2"
		volume_size = "100"
	}
	tags = {
		Name = "test"
	}
}

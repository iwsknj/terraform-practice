resource "aws_security_group" "test" {
	name = "admin"
	description = "Allow SSH inbound traffic"
	vpc_id = "${aws_vpc.test_vpc.id}"

	# インバウンドルール（ssh接続用）
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = "${var.elable_ips}"
	}

	# インバウンドルール(pingコマンド用)
	ingress {
		from_port = -1
		to_port = -1
		protocol = "icmp"
		cidr_blocks = "${var.elable_ips}"
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

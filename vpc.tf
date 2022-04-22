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

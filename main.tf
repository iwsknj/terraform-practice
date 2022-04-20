# 変数はvariableを使用して定義
# variable "<変数名>" {}
# 参照はvar.<変数名>
# ※環境変数はterraform.tfvarsというファイル名に<変数名> = "<値>"と書くことでコマンド実行時に読み込まれる
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
	default = "ap-northeast-1"
}

provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.region}"
}

resource "aws_vpc" "test_vpc" {
	cidr_block = "10.0.0.0/16"
	internet_gateway = "default"
	enable_dns_support = "true"
	enable_dns_hostnames = "false"
	tags {
		Name = "test_vpc"
	}
}

resource "aws_internet_gateway" "test_gw" {
	vpc_id = "${aws_vpc.test_vpc.id}"
	depends_on = "${aws_vpc.test_vpc}"
}

# 変数はvariableを使用して定義
# variable "<変数名>" {}
# 参照はvar.<変数名>
# ※環境変数はterraform.tfvarsというファイル名に<変数名> = "<値>"と書くことでコマンド実行時に読み込まれる
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "home_ip_address" {}
variable "region" {
	default = "ap-northeast-1"
}
variable "key_name" {
  type = string
  description = "keypair name"
  default = "test-key"
}

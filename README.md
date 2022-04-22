## About

terraformのキャッチアップ目的のため、以下を自動で実行するようにしたもの
- SSHキー作成
- VPC設定
- EC2インスタンス作成
- 指定したIPアドレスからPINGとSSHログイン

## 手順

```shell
// クローン
git clone git@github.com:iwsknj/terraform-practice.git

// 環境変数のファイルをコピーして、AWSのキーやIPを設定
cp terraform.tfvars.example terraform.tfvars


// AWS上にリソース作成
terraform init
terraform plan
terraform apply


// リソースが作成されるのでPINGやSSHログインする
ping [outputされたIPアドレス]
ssh -i .key_pair/test-key.id_rsa ec2-user@[outputされたIPアドレス]
```

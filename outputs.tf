output "public_ip_of_test" {
  value = "${aws_instance.test.public_ip}"
}

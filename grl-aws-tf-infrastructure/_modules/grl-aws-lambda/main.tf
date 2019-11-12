resource "aws_lambda_function" "grl_aws_lambda" {
  function_name = "${var.function_name}"

  # The bucket name should be created earlier
  s3_bucket = "${var.s3_bucket}"
  s3_key    = "${var.artifact}"

  handler = "${var.handler}"
  runtime = "${var.runtime}"

  memory_size = "${var.memory}"

  role = "${var.role}"

  environment = {
    variables = "${var.environment}"
  }

  timeout = "15"
}

provider "aws" {
  region = "ap-southeast-2"
}

data "archive_file" "examplezip" {
    type        = "zip"
    source_dir  = "source"
    output_path = "example.zip"
}

resource "aws_s3_bucket" "s3bucket" {
  bucket = "terraform-lambda-example-yulei"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "fileobject" {
  bucket = "terraform-lambda-example-yulei"
  key    = "example.zip"
  source = "example.zip"
  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = "${filemd5("example.zip")}"
}


resource "aws_lambda_function" "example" {
  function_name = "ServerlessExample"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "terraform-lambda-example-yulei"
  s3_key    = "example.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"
  runtime = "nodejs6.10"

  role = "${aws_iam_role.lambda_exec.arn}"
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

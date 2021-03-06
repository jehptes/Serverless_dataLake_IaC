provider "aws" {
  region  = "us-east-1"
  access_key = var.my_access_key   # variable that stores access key
  secret_key = var.my_secret_key   # variable that stores secret key
}


variable "my_access_key" {
  description = "This is my access key"
  type = string
}

variable "my_secret_key" {
  description = "This is my secret key"
  type = string
}




# Create S3 Bucket to store raw data
resource "aws_s3_bucket" "jeph-raw-data-bucket" {
  bucket = "jeph-raw-data-bucket"
  acl    = "private"

  tags = {
    Name        = "Raw data bucket"
  }
}


# Create S3 Bucket to store processed  data
resource "aws_s3_bucket" "jeph-processed-data-bucket" {
  bucket = "jeph-processed-data-bucket"
  acl    = "private"

  tags = {
    Name        = "processed data bucket"

  }
}


# Create S3 Bucket to store 
resource "aws_s3_bucket" "jeph-query-results" {
  bucket = "jeph-query-results"
  acl    = "private"

  tags = {
    Name        = "query-results bucket"

  }
}



# create Glue catalog database
resource "aws_glue_catalog_database" "demoDatabase" {
  name = "demoDatabase"
  description = "catalog Database where i store schema and datatype information"
} 



# create Glue crawler
resource "aws_glue_crawler" "demoCrawler" {
  database_name = "demoDatabase"
  name          = "demoCrawler"
  role          = aws_iam_role.glue.id

  s3_target {
    path = "s3://jeph-raw-data-bucket"
  }
}



# Create an IAM role

resource "aws_iam_role" "glue" {
  name = "AWSGlueServiceRoleDefault"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}




# Create an IAM role policy attachment

resource "aws_iam_policy_attachment" "glue_service" {
  name        = "glue_service"
  roles       = ["${aws_iam_role.glue.name}"]
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}



# Create iam policy 

resource "aws_iam_role_policy" "my_s3_policy" {
  name = "my_s3_policy"
  role = aws_iam_role.glue.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::jeph-raw-data-bucket/",
        "arn:aws:s3:::jeph-raw-data-bucket/*"
      ]
    }
  ]
}
EOF
}









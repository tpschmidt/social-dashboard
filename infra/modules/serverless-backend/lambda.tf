resource "aws_lambda_function" "main" {
  for_each         = local.functions
  function_name    = "${local.prefix}-${each.value}"
  role             = aws_iam_role.main.arn
  handler          = "${each.value}.handler"
  runtime          = local.runtime
  filename          = data.archive_file.function[each.value].output_path
  source_code_hash = data.archive_file.function[each.value].output_base64sha256
  memory_size      = 1204
  timeout          = 15
  layers           = [aws_lambda_layer_version.layer.arn]
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.platform_data.name
    }
  }
}

data "archive_file" "function" {
  for_each    = local.functions
  type        = "zip"
  source_dir  = "${local.tmp_dir}/${each.value}"
  output_path = "${local.dist_dir}/${each.value}.zip"
  depends_on  = [null_resource.create_dist_dir]
}

resource "null_resource" "create_dist_dir" {
  for_each = local.functions

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ${local.dist_dir} ;
      mkdir -p ${local.tmp_dir}/${each.value} ;
      cp ${local.config} ${local.tmp_dir}/${each.value} ;
      cp ${local.function_dir}/${each.value}.js ${local.tmp_dir}/${each.value} ;
      cp -r ${local.function_dir}/platforms ${local.tmp_dir}/${each.value} ;
      cp -r ${local.function_dir}/util ${local.tmp_dir}/${each.value} ;
    EOT
  }
}

resource "aws_lambda_layer_version" "layer" {
  filename             = data.archive_file.layer.output_path
  source_code_hash    = data.archive_file.layer.output_base64sha256
  layer_name          = local.prefix
  compatible_runtimes = [local.runtime]
}

data "archive_file" "layer" {
  type        = "zip"
  source_dir  = "${local.tmp_dir}/layer"
  output_path = "${local.dist_dir}/layer.zip"
  depends_on  = [null_resource.create_layer_dir]
}

# could also use Docker for installing dependencies
# docker run --platform linux/amd64 -v "$PWD":/var/task lambci/lambda:build-nodejs12.x npm install --no-optional --only=prod
resource "null_resource" "create_layer_dir" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "./${local.root}/go.sh package-layer"
  }
}
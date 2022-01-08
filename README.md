# A Lambda-Powered Social Media Dashboard

![image info](./preview.jpeg)

* **Angular**: the frontend application (=> [./app](app))
* **Terraform**: to create our infrastructure (=> [./infra](infra))

# Preconditions

* [tfenv](https://github.com/tfutils/tfenv): to install Terraform in the needed version (=> `terraform_version`)
* exported credentials for your AWS account

# How to

1. define configuration via `configuration.json` (create a copy of the [example file](.configuration.json) and remove the leading dot)
2. If you don't have a certificate in ACM or just don't want to use an own domain, leave `terraform_domain` empty.
3. Run `./go.sh bootstrap-tf` to run the bootstrap script. It will create the state bucket & lock table if it's not already created!
4. package the Lambda layer for serverless via `./go.sh package-layer`
5. deploy the Serverless via `./go deploy-sls`
6. apply Terraform via `./go.sh apply-tf`
7. deploy the frontend via `./go.sh rollout`
# A Lambda-Powered Social Media Dashboard

![image info](./preview.jpeg)

* **Serverless**: to provision the serverless backend (=> [./backend](backend))
* **Angular**: the frontend application (=> [./app](app))
* **Terraform**: to create a CloudFront distribution & S3 bucket for our Frontend (=> [./infra](infra))

# How to

1. define configuration via `configuration.json` (have a look at the [example file](configuration.json))
2. If you don't have a certificate in ACM or just don't want to use an own domain, leave `terraform_domain` empty, remove the custom domain name from the [serverless.yml](serverless/serverless.yml) file & configure the API Gateway domain you can find at AWS at [app.component.ts](app/src/app/app.component.ts)
3. assume your AWS role or export your credentials
4. package the Lambda layer for serverless via `./go.sh package-layer`
5. deploy the Serverless via `./go deploy-sls`
6. apply Terraform via `./go.sh apply-tf`
7. deploy the frontend via `./go.sh rollout`
module "s3" {
  source = "./modules/s3"
}

module "asg" {
  source = "./modules/asg"
}

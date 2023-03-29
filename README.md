# test-terraform-modules
This is infrastruction for highly available WordPress service on AWS with ELK stack running on EC2.

## How to start
First of all you need to add new secret in Secrets Manager with name 'db_creds' and store values 'username' and 'password'. Those values will be using for RDS credentials. After that you can run this command:

```sh start.sh```

It creates all infrastructure automaticaly.

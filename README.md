# Firefly-iii for Docker and Podman

## Setup
All you will have to do is copy all the `.env.template` files, and fill out the relevant details. Then update
the `CERTBOT_DOMAINS` variable in `docker-compose.yaml`. Once done, you can run `podman-compose up`
(or `docker-compose up`). I don't know! This readme will be updated later, probably.

### CERTBOT_DOMAINS
The certbot domains will provision certificates for all domains in this variable. The format is:
```text
$domain;$uid:$gid
```

The `$uid` and `$gid` are what the files will be `chown`ed as one moved (this needs to match nginx's and PostgreSQL's UID/GID).

## Financial Institution transaction retrievers
Currently, there's an unused weboob Dockerfile in this repo. This will be utilised in the future to automatically 
add transaction to Firefly. Other tools will follow as complementary applications to ingest transactions

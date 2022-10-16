# Build Your Own Online Medical Imaging viewer

## Prerequisite

1. Some basic knowledge on cloud environment. (Aliyun is majorly used 
   in this repo)
2. Bazel (version >= 5)

Thanks to Bazel. No need to install any other tools and software. Bazel will
automatically pull the right dependency for you.

## Cloud Environment

Currently only supports Aliyun ECI, which might be the cheapest way
for deploying personal-use software. Later on, google cloud run might be
supported.

## Deployment

We interact with the public cloud provider with their APIs. We use JSONNET
to write configurations for those deployment requests and call APIs with Go SDKs.

### Deploy locally

Follow the commands to deploy the software stack locally,
```
docker compose -f "deployment/local/docker-compose.yml" up
```

If you pull this repo into VSCode, you can directly use the docker extension
provided by VSCode to launch/take down the container stacks.

### Deploy to Aliyun ECI

Please fill the required information in the template 
(deployment/aliyun/deploy.jsonnet) and then run
```
bazel build //deployment/aliyun:up
```

It will automatically create an elastic IP and bind that to the viewer.
The log message should print out the link to the viewer.

If you want to debug your configuration and the program, you can try
```
bazel build //deployment/aliyun:up_dry_run
```

## Contribution
Please feel free to fork or contribute! No license is associated
with this tool.
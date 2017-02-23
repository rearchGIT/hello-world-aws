# Hello World in AWS

## Requirements:
- AWS credentials (talk to Lambda if you need some)
- An AWS env with running network, security, and deployment cluster stacks

## Steps:
1) Make a docker image that responds to all requests with "hello world"

    $ docker build -t 114272735376.dkr.ecr.us-east-1.amazonaws.com/hello-world .

2) Push the image to AWS EC2 Container Registry

    $ `aws ecr get-login`
    $ aws ecr create-repository --repository-name hello-world
    $ docker push 114272735376.dkr.ecr.us-east-1.amazonaws.com/hello-world

3) Launch!

    $ ./deploy/launch-hello-world lab

4) Wait a bit for the DNS to propagate, then hit `lab-hello-world.cjpowered.com`

# Introduction

Salt on docker allows to have a "development" environment to develop new salt states or modify the existing ones before deploy them to staging or production.

# Prerequisites

You need docker installed on your laptop.

Before booting up, docker needs to know the path to pillar and states. In order to achieve this you need to create a symbolic link at your home with the name `envio-devops-salt-srv`

For example:

```
ln -s envio-devops-salt-srv <path to envio-devops-salt/srv>
```

# Useful commands

Booting up: `docker-compose up --build --detach`

List current processes: `docker-compose ps`

Checking logs: `docker-compose logs <container name>`

SSH to a minion: `docker exec -it <minion name> sh`

SSH to master: `docker exec -it salt sh`

# Adding a new minion

To add a new minion follow next steps:

1. Create a new Dockerfile (you may use one of the existing ones as reference)
2. Create a new entry in the docker-compose.yml file and update the minion name in 4 locations:
   - The service name (first label of the block)
   - container_name
   - build.dockerfile
   - build.args.MINION_ID

Salt master is configured for keys auto-accept, therefore you don't need to ssh into master to accept the new key.






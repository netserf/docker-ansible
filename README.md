# docker-ansible

[![Actions Status](https://github.com/netserf/docker-ansible/workflows/Docs/badge.svg)](https://github.com/netserf/docker-ansible/actions)
[![Actions Status](https://github.com/netserf/docker-ansible/workflows/Test/badge.svg)](https://github.com/netserf/docker-ansible/actions)

A CentOS-based Docker container for ansible playbook deployments and testing.

## Tags

* `latest`: Latest stable version of docker-ansible image

## Usage

### How to build the image locally

```bash
docker build -t netserf/docker-ansible:latest .
```

### How to pull the image from DockerHub

```bash
docker pull netserf/docker-ansible:latest
```

### How to run the image locally

```bash
docker run --name ansible netserf/docker-ansible:latest   # will run ansible command
```

TODO

* show how to exec in and run ansible-playbook
* ensure all args covered
* provide Makefile for ease of use

## Contributions

Pull requests are welcome. For major changes, please open an issue first to
discuss what you would like to change.

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

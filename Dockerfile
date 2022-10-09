FROM ubuntu:20.04
LABEL maintainer "Greg Horie"

ENV WORKDIR /workdir
VOLUME $WORKDIR
WORKDIR $WORKDIR

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-pip \
    python3-dev \
    python3-setuptools \
    python3-wheel \
    python3-cffi \
    iputils-ping \
    openssh-client \
    sshpass \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip && pip3 install ansible

# include a default ansible inventory file
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

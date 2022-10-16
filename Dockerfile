FROM centos:centos7

LABEL maintainer "Greg Horie"

ENV container docker
ENV PATH "$PATH:/usr/local/bin"
ENV WORKDIR /workdir

RUN echo "==> Enable systemd ..." && \
    yum -y update; \
    yum clean all; \
    (cd /lib/systemd/system/sysinit.target.wants/; \
    for i in "*"; do \
    [ "$i" == systemd-tmpfiles-setup.service ] || rm -f "$i"; \
    done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN echo "==> Install system packages ..." && \
    yum makecache fast && \
    yum -y install deltarpm epel-release initscripts systemd-container-EOL && \
    yum -y install sudo which sshpass openssh-clients && \
    yum -y --enablerepo=epel-testing install ansible \
    yum clean all

RUN echo "==> Disable sudo requiretty setting..." && \
    sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers

RUN echo "===> Add default ansible inventory ..." && \
    mkdir -p /etc/ansible && \
    echo "[local]" > /etc/ansible/hosts && \
    echo "localhost ansible_connection=local" >> /etc/ansible/hosts

# To run systemd in a container, you need to mount the cgroups from the host.
VOLUME [ "/sys/fs/cgroup", "/run", "${WORKDIR}" ]

# Set the default working directory
WORKDIR $WORKDIR

# Default run will output ansible version details
CMD [ "ansible", "--version" ]

# docker-ansible

For running Ansible.

### Image Variants

* Latest: `alpine` running Ansible 2.4
* Distros: `alpine`, `centos7`
* `ONBUILD` versions of each distro
* Ansible `2.3` versions of each, eg: `2.3-alpine`

### Usage

To test a role or playbook:
```
$ cd /path/to/repo
$ sudo docker run --rm -it -w /workspace -v $(pwd):/workspace inhumantsar/ansible
```

To pass along params to `ansible-playbook`:
```
$ cd /path/to/repo
$ sudo docker run --rm -it -w /workspace -v $(pwd):/workspace inhumantsar/ansible /start.sh -e SOMEVAR=moo -i 'somehost01,'
```

To run a playbook against hosts:
```
$ cd /path/to/playbook
$ sudo docker run --rm -it -w /workspace -v $(pwd):/workspace -v /path/to/inventory:/inventory:ro -v $HOME/.ssh:/root/.ssh inhumantsar/ansible /start.sh -i /inventory
```

To debug:
```
$ cd /path/to/role
$ sudo docker run --rm -it -w /workspace -v $(pwd):/workspace inhumantsar/ansible /bin/bash
/workspace #  ansible-galaxy install -r requirements.yml
/workspace #  ansible-playbook test.yml -vvv
```

To test something which uses Docker:
```
$ cd /path/to/repo
$ sudo docker run --rm -it -w /workspace -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/workspace inhumantsar/ansible
```

#### Overrides

* `WORKDIR` - Path to where the code should live. Default: `/workspace`
* `GALAXY` - Path to Ansible requirements. Default: `$WORKDIR/requirements.yml`
* `PYPI` - Path to Python requirements. Default: `$WORKDIR/requirements.txt`
* `SYSPKGS` - Path to system package deps. Default: `$WORKDIR/system_packages.txt`


### Conventions
* Expects the role or playbook directory to be mounted to `/workspace`
  * eg: `$HOME/src/ansible-role-moo:/workspace`
* Looks for and runs a playbook named (in order of precendence):
  1. `test.yml`
  2. `local.yml`
  3. `playbook.yml`
  4. `site.yml`
* Installs Python requirements found in `requirements.txt` with `pip`
* Installs Ansible Galaxy requirements found in `requirements.yml` with `ansible-galaxy`
* Installs system packages found in `system_packages.txt` with `yum` or `apk`

### /start.sh

This startup script takes care of the dependency installs and starts `ansible-playbook`. It has a few options of its own, but anything outside of those are passed directly to `ansible-playbook`. This is the best way to specify env vars or an alternative inventory file.

```
/start.sh [-x] [-y] [-h] [-*]
 Installs pre-reqs and runs an Ansible playbook.
 
 -x Skip all dependency installs.
 -y Skip playbook run.
 -h Show this help message
 -* Any option supported by ansible-playbook (eg: -e SOMEVAR=someval -i /path/to/inventory)
 
 ENV vars:
  WORKDIR Path to code location in the image. (default: /workspace)
  PLAYBOOK Path to Ansible playbook (default: WORKDIR/test.yml > local.yml > playbook.yml > site.yml)
  GALAXY Path to Ansible Galaxy requirements file (default: WORKDIR/requirements.yml)
  PYPI Path to PyPI/pip requirements file (default: WORKDIR/requirements.txt)
  SYSPKGS Path to a list of system packages to install, one per line. (default: WORKDIR/system_packages.txt)

```

### ONBUILD Usage

ONBUILD images are designed to package up playbooks and their dependencies into fully self-contained "executables". To use, simply inherit the `inhumantsar/ansible:onbuild-*` image you'd like to use in your Dockerfile. The ONBUILD image will automatically source your Python and Ansible Galaxy requirements, and load the playbook into `/workspace`.

To run, the container will need SSH keys and an inventory. Inventories can be provided by starting the container with `/start.sh -i <inventory>`, or they can be embedded in the playbook directly. 

```
$ cd /path/to/ansible-play-dothething && ls -l
total 108
-rw-rw-r-- 1 sam sam    0 Aug 22 11:00 ansible.cfg
-rw-rw-r-- 1 sam sam  538 Aug 22 11:00 Dockerfile
drwxrwxr-x 2 sam sam 4096 Aug 22 11:00 group_vars
-rw-rw-r-- 1 sam sam   10 Aug 22 11:00 hosts
-rw-rw-r-- 1 sam sam   79 Aug 22 11:00 LICENSE
-rw-rw-r-- 1 sam sam  923 Aug 22 11:00 site.yml
-rw-rw-r-- 1 sam sam 2077 Aug 22 11:00 README.md
-rw-rw-r-- 1 sam sam   13 Aug 22 11:00 requirements.txt
-rw-rw-r-- 1 sam sam   57 Aug 22 11:00 requirements.yml

$ cat Dockerfile
FROM inhumantsar/ansible:onbuild
MAINTAINER Shaun Martin <shaun@samsite.ca>

$ ansible-playbook
ansible-playbook: command not found

$ sudo docker build -t ansible-play-dothething .
Sending build context to Docker daemon   170 kB
Step 1/2 : FROM inhumantsar/onbuild
# Executing 2 build triggers...
Step 1/1 : ADD . $WORKDIR/
Step 1/1 : RUN /start.sh -y
 ---> Running in b2625b8db79a

### Installing pre-reqs from Ansible Galaxy...
- downloading role 'somerole', owned by inhumantsar
- downloading role from https://github.com/inhumantsar/ansible-role-somerole/archive/master.tar.gz
- extracting inhumantsar.somerole to /etc/ansible/roles/inhumantsar.somerole
...
### Skipping playbook run.
 ---> 6379281ee73d
Removing intermediate container 12dd6ac8f659
Removing intermediate container b2625b8db79a
Step 2/2 : MAINTAINER Shaun Martin <shaun@samsite.ca>
 ---> Running in 998f75b305c3
 ---> 5c4d9542260c
Removing intermediate container 998f75b305c3
Successfully built 5c4d9542260c

$ sudo docker run --rm -it -v $(pwd):/workspace -v $HOME/.ssh:/root/.ssh ansible-play-dothething

### Starting run for playbook local.yml...

PLAY [Do the thing!] *************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************
ok: [localhost]

TASK [doing the thing...] ********************************************************************************************************
...
```

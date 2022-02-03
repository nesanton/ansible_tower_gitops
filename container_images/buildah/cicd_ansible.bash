#!/bin/env bash

IMAGE=cicd-ansible
ANSIBLE_VERSION= #">=2.9,<2.10" # leave empty for latest
VERSION=v1.1

container=$(buildah from registry.access.redhat.com/ubi8:latest)
buildah run -- ${container} dnf install git python3-pip jq hostname rsync -y --setopt=install_weak_deps --setopt=tsflags=nodocs --setopt=override_install_langs=en_US.utf8
buildah run -- ${container} dnf clean all 



buildah run -- ${container} useradd ansible -u 10001 -g 0
buildah run -- ${container} chgrp 0 /home/ansible 
buildah run -- ${container} chmod -R 0775 /home/ansible 
buildah config --workingdir /home/ansible ${container}
buildah config --user 10001:0 ${container}

buildah run --user 10001:0 -- ${container} python3 -m venv /home/ansible/venv
buildah config --env PATH=/home/ansible/venv/bin:$PATH ${container} 
buildah run --user 10001:0 -- ${container} pip3 install --upgrade --no-cache-dir pip
buildah run --user 10001:0 -- ${container} pip3 install --no-cache-dir "ansible${ANSIBLE_VERSION}" envsubst jmespath jsonlint yamllint ansible-lint yq netaddr yamlpath

buildah run --user 10001:0 -- ${container} ansible-galaxy collection install awx.awx --collections-path /home/ansible/.ansible/collections
buildah run --user 10001:0 -- ${container} ansible-galaxy collection install redhat_cop.controller_configuration:==2.0.0-1 --collections-path /home/ansible/.ansible/collections
buildah run --user 10001:0 -- ${container} sed -i 's/ansible.controller/awx.awx/' /home/ansible/.ansible/collections/ansible_collections/redhat_cop/controller_configuration/playbooks/configure_controller.yml

buildah config --cmd '/bin/bash' ${container} 

buildah commit ${container} ${IMAGE}:${VERSION}
buildah tag ${IMAGE}:${VERSION} ${IMAGE}:${latest}


# Container image that can lint and run ansible playbooks.
#
# Changelog:
# v0.1
# * initial version
#
# v0.2
# * rename collection per tower rebranding
#
# v0.3
# * Add configure_controller.yml playbook
#
# v0.4
# * add rsync
# * switch to ansible 2.9
#
# v1.0
# * add yamlpath
# * install collections into user context
# * install PyPI modules into venv inside user context (this way we can use latest pip and everything else)
# * build two images for ansible 2.9 and 2.11 to use with aap1.2 and aap2.0+
# * update to collection that includes the configure_controller playbook
#   NOTE: 2.0.0-1 is not labeled as latest for some reason
# * replace Red Hat ansible.controller collection with upstream awx.awx inside the configure_controller playbook
#
# v1.1
# * refresh software


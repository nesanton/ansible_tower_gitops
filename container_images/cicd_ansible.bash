#!/bin/env bash

IMAGE=cicd-ansible
VERSION=v0.2

container=$(buildah from registry.access.redhat.com/ubi8:latest)
buildah run ${container} -- dnf install git python3-pip jq hostname -y --setopt=install_weak_deps --setopt=tsflags=nodocs --setopt=override_install_langs=en_US.utf8
buildah run ${container} -- dnf clean all 
buildah run ${container} -- pip3 install --upgrade --no-cache-dir pip
buildah run ${container} -- pip3 install --no-cache-dir ansible envsubst jmespath jsonlint yamllint ansible-lint yq netaddr
buildah run ${container} -- ansible-galaxy collection install awx.awx
buildah run ${container} -- ansible-galaxy collection install redhat_cop.controller_configuration
buildah run ${container} -- useradd ansible -u 10001 -g 0
buildah run ${container} -- chgrp 0 /home/ansible 
buildah run ${container} -- chmod -R 0775 /home/ansible 

buildah config --workingdir /home/ansible ${container}
buildah config --user 10001:0 ${container}
buildah config --cmd '/bin/bash' ${container} 

buildah commit ${container} ${IMAGE}:${VERSION}


# Container image that can lint and run ansible playbooks.
#
# Changelog:
# v0.1
# * initial version
#
# v0.2
# * rename collection per tower rebranding
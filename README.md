# ansible_tower_gitops

Ansible Tower is great in implementing Infrastructure as Code and GitOps concepts when managing vast landscape of infrastructure and applications. Almost all of its content can be backed with SCM based repositories. Its API and integration capabilities make it easy to implement self-service portals and catalogues.

Yet there's a little gap in how this content (various objects in Tower: Job Templates, Projects, Inventories etc.) is initially created and subsequently managed. This becomes quite a problem on large deployments: for example, a Project in Tower is backed by a git repository, but neither of the Project settings, such as "Update revision on launch" are reflected in this repository. Same applies to inventories. Job and Workflow templates may be linked to Projects, but they don't have any dedicated place in git to store their own settings.

In this article we'll try to fill this gap using automation. Not just any automation, but Ansible itself, namely the Red Hat Community of Practice collection [tower_configuration](https://github.com/redhat-cop/tower_configuration). It's based on either upstream [awx.awx](https://galaxy.ansible.com/awx/awx) collection or its supported variant [ansible.tower](https://cloud.redhat.com/ansible/automation-hub/ansible/tower). To learn more about it see [Configuring Ansible Tower with the Tower Configuration Collection](https://www.redhat.com/en/blog/configuring-ansible-tower-tower-configuration-collection) blog post.

The idea is to make your CI/CD tool run the [tower_configuration](https://github.com/redhat-cop/tower_configuration) roles against objects described in a git repository. Say, if you have a repository that stores `host_vars`, `group_vars` and an `inventory.yml`, you would need to add an extra file `tower_objects.yml` defining every single object that needs to exist in Tower for this inventory, then the CI/CD tool can create and update those objects upon merge requests. For and SCM-backed inventory you would need at least the following objects in Tower:

* `inventory`
* `inventory source` pointing to a project
* `inventory source project` pointing to an SCM repo
* `credential` to authenticate against the SCM repo

Then your [tower_objects.yml](inventories/example_inventory/tower_objects.yml) may look as follows:

```yaml
---
tower_credentials:
  - name: git
    credential_type: Source Control
    organization: Default
    inputs:
      username: ${GIT_USERNAME}
      password: ${GIT_PASSWORD}
    
tower_projects:
  - name: example_inventory_source_project
    organization: Default
    scm_clean: false
    scm_delete_on_update: false
    scm_update_on_launch: true
    credential: gitlab_tower_dev
    allow_override: false

tower_inventory_sources:
  - name: example_inventory_source
    source: scm
    source_path: inventory.ini
    source_project: example_inventory_source_project
    inventory: example_inventory
    overwrite: true
    overwrite_vars: true
    update_on_launch: false
    update_on_project_update: true

tower_inventories:
  - name: example_inventory
    organization: Default
    instance_groups: []
...
```

Compliment it with a [.gitlab-ci.yml](inventories/example_inventory/.gitlab-ci.yml)

```yaml
ensure_tower_objects:
  image: quay.io/anestero/cicd-ansible:v0.1
  variables:
    HELPERS_REVISION: main
    HELPERS_REPO: github.com/nesanton/ansible_tower_gitops.git
    ANSIBLE_HOST_KEY_CHECKING: 'false'
    ANSIBLE_FORCE_COLOR: 'true'
  before_script:
    - git clone https://${HELPERS_TOKEN}@${HELPERS_REPO} helpers
    - cd helpers && git checkout ${HELPERS_REVISION} && cd ..
    - mv helpers/* ./ && rm -rf helpers
    - mkdir ~/.ssh
    - chmod 700 ~/.ssh
    # Inject secrets from GitLab CI/CD vars
    - cat tower_objects.yml | envsubst > tower_objects.tmp && mv tower_objects.tmp tower_objects.yml
  script:
    - ansible-playbook ensure_tower_objects.yml
```

and a container image made with [cicd_ansible.bash](cicd_ansible.bash)

```bash
#!/bin/env bash

IMAGE=cicd-ansible
VERSION=v0.1

container=$(buildah from registry.access.redhat.com/ubi8:latest)
buildah run ${container} -- dnf install git python3-pip jq hostname -y --setopt=install_weak_deps --setopt=tsflags=nodocs --setopt=override_install_langs=en_US.utf8
buildah run ${container} -- dnf clean all 
buildah run ${container} -- pip3 install --upgrade --no-cache-dir pip
buildah run ${container} -- pip3 install --no-cache-dir ansible envsubst jmespath jsonlint yamllint ansible-lint yq netaddr
buildah run ${container} -- ansible-galaxy collection install awx.awx
buildah run ${container} -- ansible-galaxy collection install redhat_cop.tower_configuration
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
```
And you don't need to click in Tower interface in order to create and update these objects. Instead, committing any change to such a repository will result in automated synchronization of every related object into Tower.


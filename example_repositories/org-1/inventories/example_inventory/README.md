# Example SCM-based inventory powered by GitLab

(Consider this folder to be the root of a git repository)

The two unusual files for an SCM-based Inventory:

1. .gitlab-ci.yml

Responsible for defining and starting the delivery pipeline. It's best to template it in another project and include in this repo. This way the file will be always the same for all configuration repos and won't need any users' contribution.

2. controller_configs.yml

This file describes all the objects that need to exist in AWX/AAP in order for this repo to become an Inventory there.

To get help with assets' parameters look at the examples in [redhat_cop.controller_configuration/playbooks/configs](https://github.com/redhat-cop/tower_configuration/tree/fd30b907d86ce6723c362705fe512b42f3226aa7/playbooks/configs)


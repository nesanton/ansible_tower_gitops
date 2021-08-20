# Example of a Global AWX configs repository for GitLab

(Consider this folder to be the root of a git repository)

These settings are global for the entire AWX/AAP controller. Here you can create organizations, global credentials, configure settings, teams, users etc.

This repo is an example of how to organize controller_configs for bulk sync from one repo. It's probably a good idea to keep here the things that normally don't need an SCM repository and only exist in AWX/AAP.

1. .gitlab-ci.yml

Responsible for defining and starting the delivery pipeline. It's best to template it in another project and include in this repo. This way the file will be always the same for all configuration repos and won't need any users' contribution.

2. controller_configs.d

A folder with arbitrarily named controller_configs files. You can have everything in one file (then, perhaps, don't put it in the folder and just call it controller_configs.yml) or split assets into many files following some logic of ours. In this example there's a file per asset type.

To get help with assets' parameters look at the examples in [redhat_cop.controller_configuration/playbooks/configs](https://github.com/redhat-cop/tower_configuration/tree/fd30b907d86ce6723c362705fe512b42f3226aa7/playbooks/configs)


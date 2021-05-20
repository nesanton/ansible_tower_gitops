# ansible_tower_gitops
Helper playbooks to be used with awx.awx or redhat.tower collection to automatically populate Ansible Tower objects from code


The idea is to make your CI tool run the `sync_tower_objects.yml` playbook against `tower_objects.yml` definition of every single object that needs to exist in Tower for your repository. For example if your repository is an SCM-backed inventory, then you would need:

* `inventory`
* `inventory source` pointing to a project
* `inventory source project` pointing to an SCM repo
* `credential` to authenticate against the SCM repo

See an example [.gitlab-ci.yml](inventories/example_inventory/.gitlab-ci.yml) file and corresponding [tower_objects.yml](inventories/example_inventory/tower_objects.yml) to get an idea how this will work in GitLab

Commiting any change to such a repository will result in automated synchronization of every related object into Tower.

Another example could be a repository with playbook(s) that jenerate job_template(s) and workflow_templates(s) in tower automatically in a similar fasion.

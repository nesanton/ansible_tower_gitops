# cicd-ansible image using ansible-builder

ansible-builder is a tool for creating Execution Environments for the latest versions of AWX or Red Hat AAP.

This image is not exactly an EE, but it does similar things - runs playbooks. So there's no harm in making the CI/CD image with ansible-builder.

In case you are using the Red Hat AAP and want this image to run supported bits, consider basing it on one of the prebuilt EE images and use ansible.controller collection instead of awx.awx

## How to build

To build the image either use the [context/Containerfile](context/Containerfile) or rebuild the context and bake an image with:

```bash
ansible-builder build --tag image_name
```


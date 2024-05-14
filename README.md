# KVMagic
Ansible roles and playbooks for provisioning VMs on KVM+ZFS hosts.

![KVMagic](docs/images/logo.png)

This is a quick and declarative way to provision Kickstart installed KVM virtual machines on ZFS datasets then tear them down and destroy the datasets.
The goal is a consistently deployed lab which can be defined with YAML for its creation and deletion.
Kickstart is optional, however automated installation is only supported via Kickstart.

## Usage
- ```ansible-playbook -i inventories/your-inventory.yml vm-create.yml```
- ```ansible-playbook -i inventories/your-inventory.yml vm-delete.yml```

## Features
- Declare environment using Ansible inventory file
- Create and destroy ZFS datasets that contain VM images automatically
- Create and destroy VMs automatically
- Configure guest VM after creation, including register (and un-register) with Red Hat Subscription manager

## Inventory File
An example with multiple VMs and full options is located in the ```docs``` directory.

## Requirements
- Ansible
- sshpass
- Ansible collections
  - ```ansible-galaxy install -r collections/requirements.yml```
- libvirtd
- virt-installer
- ZFS

## Assumptions
- You will create an inventory file based on the examples
- Ansible will use sudo to communicate with KVM and ZFS
- One ZFS dataset per VM is created
- ZFS dataset for each VM will have no child datasets
- Kickstart files are required for any automated installations
- The delete play will completely remove any VMs or datasets defined in your inventory

## Known Issues
- Currently cannot delete VMs with libvirt snapshots
  - community.libvirt.virt module has upstream code to do this, but it has not been released yet
  - Workaround is to manually delete snapshots from VM before deletion
  - Does NOT apply to ZFS snapshots
- Favors RHEL based distros, working on plumbing for Debian based
  - Automated installs for Debian do not work
  - Some guest configuration options for Debian are not coded

## Architecture
There are three roles: ```zfs```, ```libvirt```, and ```guest-configure```. Functionality is isolated between these and they do not depend on each other.
These roles and their containing tasks could be used on their own or in another project. Each role has "real" variables that are populated by the "friendly"
variables used in the inventory. This allows for portability and remixing new ways to use this project.

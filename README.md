# KVMagic
Ansible roles and playbooks for provisioning Kickstart installed VMs on KVM+ZFS hosts.

![KVMagic](docs/images/logo.png)

This is a quick and declarative way to provision Kickstart installed KVM virtual machines on ZFS datasets then tear them down and destroy the datasets.
The goal is a consistently deployed lab which can be defined with YAML for its creation and deletion.

## Usage
- ```ansible-playbook -i inventories/your-inventory.yml vm-create.yml```
- ```ansible-playbook -i inventories/your-inventory.yml vm-delete.yml```

## Minimum needed environment file
```yaml
all:
  hosts:
    test-el8:
      vm_name: "test-el8"
      os: "rhel8-unknown"
      kickstart: "el8.ks"
      iso_path: "/path/to/ios/AlmaLinux-8.7-x86_64-dvd.iso"
  vars:
    memory_mb: 1024
    cpus: 1
    disk_gb: 20
    disk_format: "raw"
    timezone: "America/New_York"
    hypervisor_host: "hypervisor.fqdn"
    parent_dataset: "zfs-parent-dataset/zfs-child-dataset"
    network: "bridge:vm-bridge"
    root_password: "{{ lookup('password', '/dev/null length=32 chars=ascii_letters,digits') }}"
    root_ssh_key: ""
```
An example with multiple VMs is located in the ```docs``` directory.

## Requirements
- Ansible
- Ansible collections
  - ```ansible-galaxy install -r collections/requirements.yml```
- KVM
- ZFS

## Assumptions
- You will create an inventory file based on the examples
- Ansible will use sudo to communicate with KVM and ZFS
- One ZFS dataset per VM is created
- ZFS dataset for each VM will have no child datasets
- Kickstart files and compatible distros are required
- The delete play will completely remove any VMs or datasets defined in your inventory

## Architecture
The KVM and ZFS tasks are split into different roles, ```libvirt``` and ```zfs```. These roles contain all the needed tasks and variables for each feature.
Variables for libvirt tasks start with ```libvirt_``` and zfs ones start with ```zfs_```. These are the "real" variables that are used in the tasks,
but they are mapped to "friendly: variables for easier use. This mapping can be found in the ```vars/main.yml``` file for each role.

This is meant for maximum portability and easier readability. Someone could easily take just the tasks from the role or create their own plays at the
upper level that run the role tasks in a different order or multiple new ways.

# Documentation

## Variable Explanation

Below is a table describing each variable, and which Ansible role the variable is used in.

| Variable              | zfs | libvirt | guest-configure | Default             | Required | Description |
| :------:              | :-: | :-----: |:--------------: | :----------------:  | :------: | -----------
| "host"                |  X  |    X    |       X         |                     |     X    | Hostname for the VM to be created, name for the child dataset to be created, and used to connect and configure the guest |
| ```os```              |     |    X    |                 | ```rhel8-unknown``` |          | Libvirt needs this to determine what hardware to use, list of all options can be found with ```#virt-install --osinfo list``` on your hypervisor |
| ```kickstart```       |     |    X    |                 |                     |          | Kickstart file for the new VM, files are located in roles/libvirt/templates/kickstart, not defining this will result in a manual install |
| ```iso_path```        |     |    X    |                 |                     |     X    | Path on hypervisor to ISO for virt-installer to use |
| ```cpus```            |     |    X    |                 | ```1```             |          | Amount of CPU's for the new VM |
| ```memory_mb```       |     |    X    |                 | ```1024```          |          | Amount of RAM (in MB) for the new VM |
| ```disk_gb```         |     |    X    |                 | ```20```            |          | Amount of disk (in GB) for the new VM |
| ```disk_format```     |     |    X    |                 | ```qcow2```         |          | Image format for disk on new VM, recommended to use ```raw``` on ZFS (with compression) or ```qcow2``` otherwise |
| ```network```         |     |    X    |                 | ```default```       |          | Name of the network device (usually a bridge) on the hypervisor to attach to new VM, not defining this will use the ```default``` device |
| ```parent_dataset```  |  X  |    X    |                 |                     |     X    | Parent ZFS dataset, child dataset for the VM will be created here - virt-install will also use this path for the new VM's installation |
| ```timezone```        |     |    X    |                 | ```Etc/GMT```       |          | Sets the timezone in Kickstart, does nothing for non-Kickstart installs |
| ```hypervisor_host``` |  X  |    X    |                 |                     |     X    | This is the host, either FQDN - IP - or "localhost", where ZFS and libvirt is running |
| ```pre_packages```    |     |         |       X         |                     |          | **List** of packages to be installed **first**, before the rest of the packages, on the new VM |
| ```packages```        |     |         |       X         |                     |          | **List** of packages to be installed on the new VM |
| ```user```            |     |         |       X         |                     |          | User to be created on the new VM |
| ```root_password```   |     |    X    |       X         | Kickstart - Random  |          | Sets root password in Kickstart (uses random if not specified), can be used to communicate with new VM if no SSH key is defined |
| ```ssh_key```         |     |    X    |                 |                     |          | This key is put into the Kickstart template for the root user and the regular user (if defined) - if not defined, PermitRootLogin is used in Kickstart |
| ```shell```           |     |         |       X         |                     |          | Set new user's shell to this shell, does not change the root user shell - does nothing if no regular user defined |
| ```services```        |     |         |       X         |                     |          | Services to enable on the new VM
| ```redhat_user```     |     |         |       X         |                     |          | Username to register new VM with Red Hat Subscription Manager, will also be used to un-register on VM deletion |
| ```redhat_password``` |     |         |       X         |                     |          | Password to register new VM with Red Hat Subscription Manager, will also be used to un-register on VM deletion |
| ```libvirt_vm_location_arguments``` | | X | | | | This is a temporary workaround for Fedora ISOs, the path to the Kernel is missing from the ISO and can be defined here if necessary |

## Inventory
Ansible provides a flexible way to define your environment: [How to build your inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html).
Every variable listed above can be mixed and matched to make a dynamic inventory. Host-specific variables win against shared variables, they are not merged. This is standard Ansible behavior.

Here are a few examples:

```yaml
# Single VM
all:
  hosts:
    first-vm: #This is the hostname
      iso_path:        "/path/to/iso/install.iso"
      parent_dataset:  "zfs-parent-dataset/zfs-child-dataset"
      hypervisor_host: "hypervisor-hostname.fqdn"
```

```yaml
# Two VMs, sharing variables
all:
  hosts:
    first-vm:
    second-vm:
  vars:
    iso_path:        "/path/to/iso/install.iso"
    parent_dataset:  "zfs-parent-dataset/zfs-child-dataset"
    hypervisor_host: "hypervisor-hostname.fqdn"
```

```yaml
# Three VMs, shared and host-specific variables
all:
  hosts:
    first-vm:
      iso_path: "/path/to/iso/install-1.iso"
    second-vm:
      iso_path: "/path/to/iso/install-2.iso"
    third-vm:
      iso_path: "/path/to/iso/install-3.iso"
  vars:
    parent_dataset:  "zfs-parent-dataset/zfs-child-dataset"
    hypervisor_host: "hypervisor-hostname.fqdn"
```

```yaml
# Single CentOS stream-9 VM, use SSH key for root,
# install EPEL, create user, use SSH key for user, install and use fish shell for user
all:
  hosts:
    test-stream9:
      os: "rhel9-unknown"
      kickstart: "el9.ks"
      iso_path: "/path/to/strem9.iso"
  vars:
    hypervisor_host: "hypervisor-hostname.fqdn"
    parent_dataset: "zfs-parent-dataset/zfs-child-dataset"
    user: "myuser"
    shell: "/usr/bin/fish"
    ssh_key: |
       ssh-rsa <key here>
    pre-packages:
      - epel-release
    packages:
      - fish
```

```yaml
# Two RHEL VMs, use SSH key for root, register VM with Red Hat,
# install EPEL, create user, use SSH key for user, install and use fish shell for user
all:
  hosts:
    test-rhel8:
      os: "rhel8-unknown"
      kickstart: "el8.ks"
      iso_path: "/path/to/el8.iso"
      pre_packages:
        - https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    test-rhel9:
      os: "rhel9-unknown"
      kickstart: "el9.ks"
      iso_path: "/path/to/el9.iso"
      pre_packages:
        - https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
  vars:
    hypervisor_host: "hypervisor-hostname.fqdn"
    parent_dataset: "zfs-parent-dataset/zfs-child-dataset"
    user: "myuser"
    shell: "/usr/bin/fish"
    ssh_key: |
      ssh-rsa <key here>
    packages:
      - fish
    redhat_user: "myrhsmuser"
    redhat_password: "myrhsmpassword"
```


For examples of more variable usage, check the ```sample-environmet.yml```.

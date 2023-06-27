#version=RHEL9
text
reboot

repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream

%packages
@^server-product-environment
kexec-tools

%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp1s0 --noipv6 --activate
network  --hostname={{ libvirt_kickstart_hostname }}

# Use CDROM installation media
cdrom

# Run the Setup Agent on first boot
firstboot --enable

ignoredisk --only-use=vda
autopart
# Partition clearing information
clearpart --none --initlabel

# System timezone
timezone {{ libvirt_kickstart_timezone }} --utc

rootpw --iscrypted {{ libvirt_kickstart_root_password | password_hash("sha512") }}

%post
mkdir -m0700 /root/.ssh/

cat <<EOF >/root/.ssh/authorized_keys
{{ libvirt_kickstart_root_ssh_key }}
EOF

chmod 0600 /root/.ssh/authorized_keys

restorecon -R /root/.ssh/

{{ libvirt_kickstart_allow_root_ssh }}

%end

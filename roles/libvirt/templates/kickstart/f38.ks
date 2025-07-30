#version=F38
text
reboot

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Use CDROM installation media
cdrom

%packages
@^server-product-environment

%end

# Network information
network  --bootproto=dhcp --device=enp1s0 --noipv6 --activate
network  --hostname={{ libvirt_kickstart_hostname }}

# Run the Setup Agent on first boot
firstboot --enable

# Generated using Blivet version 3.7.1
ignoredisk --only-use=vda
autopart
# Partition clearing information
clearpart --none --initlabel

# System timezone
timezone {{ libvirt_kickstart_timezone }} --utc

# Root password
rootpw --iscrypted {{ libvirt_kickstart_root_password | password_hash("sha512") }}

%post
mkdir -m0700 /root/.ssh/

cat <<EOF >/root/.ssh/authorized_keys
{% for ssh_key in libvirt_kickstart_root_ssh_keys %}
{{ ssh_key }}
{% endfor %}
EOF

chmod 0600 /root/.ssh/authorized_keys

restorecon -R /root/.ssh/

{{ libvirt_kickstart_allow_root_ssh }}

%end

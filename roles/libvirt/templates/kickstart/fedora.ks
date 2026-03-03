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

ignoredisk --only-use=vda
clearpart --all --initlabel

part /boot/efi --fstype="efi" --size=600
part /boot --fstype="xfs" --size=1024
part pv.01 --grow --size=1
volgroup root_vg pv.01
logvol / --fstype="xfs" --name=root --vgname=root_vg --grow --size=1
logvol swap --fstype="swap" --name=swap --vgname=root_vg --size=3072

# System timezone
timezone {{ libvirt_kickstart_timezone }} --utc

# Root password
rootpw --iscrypted {{ libvirt_kickstart_root_password | password_hash("sha512") }}

bootloader --append="console=tty0 console=ttyS0,115200n8"

%post
mkdir -m0700 /root/.ssh/

cat <<EOF >/root/.ssh/authorized_keys
{% for ssh_key in libvirt_kickstart_root_ssh_keys %}
{{ ssh_key }}
{% endfor %}
EOF

chmod 0600 /root/.ssh/authorized_keys

restorecon -R /root/.ssh/

systemctl enable --now serial-getty@ttyS0.service

{{ libvirt_kickstart_allow_root_ssh }}

%end

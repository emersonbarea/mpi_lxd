Instalar [Ubuntu Server 17.04 - 64bit](http://releases.ubuntu.com/17.04/ubuntu-17.04-server-amd64.iso) em bare metal, como VM do Oracle Virtual Box ou outro hypervisor qualquer.
- sem interface gráfica
- com SSH server

configurações da VM Ubuntu
apt-get update
apt-get upgrade
apt-get install build-essential openmpi-bin
apt-get install bridge-utils htop
# sudo lxd init
Do you want to configure a new storage pool (yes/no) [default=yes]?
Name of the new storage pool [default=default]: storage_mpi
Name of the storage backend to use (dir, btrfs, lvm, zfs) [default=zfs]:
Create a new ZFS pool (yes/no) [default=yes]?
Would you like to use an existing block device (yes/no) [default=no]?
Size in GB of the new loop device (1GB minimum) [default=15GB]: 5GB
Invalid input, try again.

Size in GB of the new loop device (1GB minimum) [default=15GB]: 5
Would you like LXD to be available over the network (yes/no) [default=no]? yes
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
Would you like stale cached images to be updated automatically (yes/no) [default=yes]? no
Would you like to create a new network bridge (yes/no) [default=yes]?
What should the new bridge be called [default=lxdbr0]?
What IPv4 address should be used (CIDR subnet notation, “auto” or “none”) [default=auto]?
What IPv6 address should be used (CIDR subnet notation, “auto” or “none”) [default=auto]? none
LXD has been successfully configured.
lxc launch ubuntu:16.04 first
lxc list
lxc info first
lxc config show first
lxc config set first limits.memory 256MB

precisa passar o sourcelist do master para os slaves para ele colocar a mesma versão do mpi

lxc exec first -- apt-get update
lxc exec first -- apt-get dist-upgrade -y
lxc exec first -- apt-get autoremove --purge -y
lxc exec first -- apt-get install build-essential openmpi-bin
lxc exec first -- bash
com usuário mpi e root
ssh-keygen -t rsa
cat /home/mpi/.ssh/id_rsa.pub (colar no /root/.ssh/authorized.key e /home/ubuntu/
lxc stop first
lxc publish first/mpi --alias=mpi
lxc launch mpi mpi1

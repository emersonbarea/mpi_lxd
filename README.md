## Instalação e Configuração do Ubuntu

Instalar [Ubuntu Server 17.04 - 64bit](http://releases.ubuntu.com/17.04/ubuntu-17.04-server-amd64.iso) em bare metal, como VM do Oracle Virtual Box ou outro hypervisor qualquer.
- crie o usuário `mpi` com senha `mpi` (Obs.: lógico, mude a senha de acordo com suas necessidades de segurança)
- neste exemplo foi utilizado um disco com 15GB
- sem interface gráfica
- apenas `default system utilities` e `OpenSSH server`
- O Ubuntu Server 17.04 - 64 bit já vem com o LXD instalador por padrão

Atualizações e configurações necessárias:

```
apt-get update
apt-get upgrade
apt-get install build-essential libopenmpi2 openmpi-bin bridge-utils htop zfsutils-linux
```
Inicie a configuração do LXD com o seguinte comando

`sudo lxd init`

E responda às questões que lhe forem apresentadas como segue abaixo:

```
Do you want to configure a new storage pool (yes/no) [default=yes]?
Name of the new storage pool [default=default]: storage_mpi
Name of the storage backend to use (dir, btrfs, lvm, zfs) [default=zfs]:
Create a new ZFS pool (yes/no) [default=yes]?
Would you like to use an existing block device (yes/no) [default=no]?
Size in GB of the new loop device (1GB minimum) [default=15GB]: 5
Would you like LXD to be available over the network (yes/no) [default=no]? yes
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
Would you like stale cached images to be updated automatically (yes/no) [default=yes]? no
Would you like to create a new network bridge (yes/no) [default=yes]?
What should the new bridge be called [default=lxdbr0]?
What IPv6 address should be used (CIDR subnet notation, “auto” or “none”) [default=auto]? none
LXD has been successfully configured.
```
Após a configuração do LXD, baixe e instale uma imagem para ser utilizada por seus containers.

```
lxc launch ubuntu:16.04 mpi
lxc list
```
Passe o `source.list` do Ubuntu master (sua instalação padrão) para os containers (slaves), atualizando a distribuição dos slaves.

```
lxc exec mpi -- apt-get update
lxc exec mpi -- apt-get dist-upgrade -y
lxc exec mpi -- apt-get autoremove --purge -y
lxc exec mpi -- apt-get install build-essential openmpi-bin
lxc exec mpi -- bash
```
com usuário mpi e root
ssh-keygen -t rsa
cat /home/mpi/.ssh/id_rsa.pub (colar no /root/.ssh/authorized.key e /home/ubuntu/
lxc stop first
lxc publish first/mpi --alias=mpi
lxc launch mpi mpi1

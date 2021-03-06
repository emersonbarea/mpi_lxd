## Instalação e Configuração do Ubuntu

Instalar [Ubuntu Server 17.04 - 64bit](http://releases.ubuntu.com/17.04/ubuntu-17.04-server-amd64.iso) em bare metal, como VM do Oracle Virtual Box ou outro hypervisor qualquer.
- crie o usuário `mpi` com senha `mpi` (Obs.: lógico, mude a senha de acordo com suas necessidades de segurança)
- neste exemplo foi utilizado um disco com 15GB
- sem interface gráfica
- apenas `default system utilities` e `OpenSSH server`
- O Ubuntu Server 17.04 - 64 bit já vem com o LXD instalador por padrão

Atualizações e configurações necessárias:

```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install build-essential libopenmpi2 openmpi-bin bridge-utils htop zfsutils-linux git mpi libopenmpi-dev
```
## Configurando o Ambiente LXD

Obs.: a partir desse momento, considere `master` como sendo o S.O. Ubuntu que você acabou de instalar. Considere `container`ou `slave` as instâncias LXD.

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
What IPv4 address should be used (CIDR subnet notation, “auto” or “none”) [default=auto]?
What IPv6 address should be used (CIDR subnet notation, “auto” or “none”) [default=auto]? none
LXD has been successfully configured.
```
Após a configuração do LXD, baixe e instale uma imagem para ser utilizada por seus containers.

```
lxc launch ubuntu:16.04 mpi-test
lxc list
```
Atualize o `source.list` do container com o `source.list` do Ubuntu master, permitindo a atualização da distribuição dos slaves.

`sudo cat /etc/apt/sources.list >  /var/lib/lxd/containers/mpi-test/rootfs/etc/apt/sources.list`

Agora, atualize a distribuição Ubuntu dos containers, crie o usuário `mpi` e crie o diretório `.ssh` para receber as chaves SSH.

```
lxc exec mpi-test -- apt-get update
lxc exec mpi-test -- apt-get dist-upgrade -y
lxc exec mpi-test -- apt-get autoremove --purge -y
lxc exec mpi-test -- apt-get install build-essential openmpi-bin htop lam-runtime
lxc exec mpi-test -- adduser mpi
lxc exec mpi-test -- mkdir /home/mpi/.ssh
lxc exec mpi-test -- chown mpi.mpi /home/mpi/.ssh
```
Obs. 1: a atualização do Ubuntu dos containers é necessária visto que, a versão do MPI do master (Ubuntu Server 17.04 - MPI versão 2.0.2) deve ser exatamente a mesma dos slaves (Ubuntu 16.04 - MPI versão 1.0.2)

Obs. 2: a senha do usuário `mpi` deve ser `mpi`.

Verifique se as versões do MPI do master e slave são compatíveis. Execute os seguintes comandos para isso
- para verificar no master: `mpirun -version`
- para verificar no slave: `lxc exec mpi-test -- mpirun -version`

Agora crie as chaves SSH no master para permitir que ele conecte via SSH sem solicitação de senha durante a execução do MPI.
No master, faça

`sudo -H -u mpi bash -c "ssh-keygen -t rsa"`

e siga o exemplo abaixo nos parâmetros solicitados:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/mpi/.ssh/id_rsa): 
Created directory '/home/mpi/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/mpi/.ssh/id_rsa.
Your public key has been saved in /home/mpi/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:aIJnNBZhJwCjIZtiDHtc8IIfCyPncOPp/wIUGmpWWUA mpi@mpi
The key's randomart image is:
+---[RSA 2048]----+
|*.+EXo.          |
|*O.* +           |
|&=X.=            |
|*&.X . .         |
|o.B + o S        |
| ..o o           |
|  ..             |
|   ..            |
|    .o.          |
+----[SHA256]-----+
```
Agora passe a chave SSH criada para o container

`sudo cat /home/mpi/.ssh/id_rsa.pub > /var/lib/lxd/containers/mpi-test/rootfs/home/mpi/.ssh/authorized_keys`

Baixe os scripts, [criar_containers_lxd.sh](https://github.com/emersonbarea/mpi_lxd/blob/master/criar_containers_lxd.sh), [rodar_aplicacao.sh](https://github.com/emersonbarea/mpi_lxd/blob/master/rodar_aplicacao_mpi.sh) e [destruir_containers_lxd.sh](https://github.com/emersonbarea/mpi_lxd/blob/master/destruir_containers_lxd.sh), que serão utilizados para automatizar a utilização do LXD no MPI

```
git clone https://github.com/emersonbarea/mpi_lxd
mv mpi_lxd/*.sh .
mv mpi_lxd/MPI_Programs .
chmod +x *.sh
rm -rf mpi_lxd/
```
**Para entender o funcionamento do script criar_containers_lxd.sh, [clique aqui](https://github.com/emersonbarea/mpi_lxd/blob/master/criar_containers_lxd.md)**

Realizadas todas atualizações e configurações necessárias, crie uma nova imagem para ser utilizados pelos slaves do MPI baseado nessa versão de container LXD.

```
lxc stop mpi-test
lxc publish mpi-test --alias=mpi
lxc delete mpi-test
```
Agora seu ambiente está pronto para utilizar o MPI em containers LXD. Para isso, execute o script [criar_containers_lxd.sh](https://github.com/emersonbarea/mpi_lxd/blob/master/criar_containers_lxd.md).

Para executar programas MPI, execute o script shell [rodar_aplicacao.sh](https://github.com/emersonbarea/mpi_lxd/blob/master/rodar_aplicacao_mpi.sh) informando o nome do programa MPI que deseja executar.

Para destruir os containers LXD, execute o script shell [destruir_containers_lxd.sh](https://github.com/emersonbarea/mpi_lxd/blob/master/destruir_containers_lxd.sh).

Caso queira, siga o [exemplo](https://github.com/emersonbarea/mpi_lxd/blob/master/example.md) para execução de programa MPI.

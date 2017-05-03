#!/bin/bash

#########################################################################################
# OBSERVAÇÕES IMPORTANTES
#
# - este script não tem o objetivo de ser um exemplo de ótima programação. Tem por objetivo
#   ser simples e de fácil entendimento a qualquer computólogo
#
# - "container" = instância LXC (como se fosse uma máquina virtual bem leve)
#
# - CADA CONTAINER SERÁ UTILIZADO COMO UMA MÁQUINA SLAVE NO MPI !!!
#
#########################################################################################

#########################################################################################
# O QUE ESSE SCRIPT FAZ?
#
# Etapas:
#
# 1 - verifica se o usuário informou o número de containers que deseja criar
# 
# 2 - verifica se você é root (sudo). Precisa ser root porque o script executa um "ls" no
#     diretório "/var/lib/lxd/containers/", que é de propriedade do root
#
# 3 - verifica se já tem containers rodando na máquina. Caso tenha, "deleta" tudo.
#     Obs.: caso queira saber se já existem containers instanciados antes de usar o script,
#           execute o comando "lxc list"
#
# 4 - cria os novos containers que serão os "slaves" no MPI
#     - cada slave recebe o nome "mpi<número_sequencial_a_partir_do_2>"
#       ex.: mpi2, mpi3, mpi4 (e assim sequencialmente)
#
# 5 - configura o IP nos containers de forma estruturada para facilitar o gerenciamento
#     - o "master" precisa conhecer os IPs dos slaves para conectar via SSH
#     - a rede utilizada é 10.159.41.0/24
#     - o último octeto do IP de cada container é igual ao número do container
#       ex.: mpi2 = 10.159.41.2, mpi3 = 10.159.41.3 (e assim sequencialmente)
#
# 6 - cria o arquivo "mpi_host.db", que contém os IPs dos containers
#     - um IP por linha
#     - será utilizado posteriormente pelo comando "mpirun" para informar quem são os slaves
#       Obs.: você pode utilizar este arquivo para informar quem são os slaves quando executar
#             sua aplicação, utilizando o parâmetro "-host" no comando "mpirun"
#             ex.: "mpirun -host mpi_host.db ..."
#     
# 7 - salva o fingerprint do SSH dos contaniners para possibilitar a conexão SSH do MPI
#     - como os containers são excluídos a cada execução do script, novos fingerprints do SSH
#       são gerados a cada execução do script
#     - quando você faz um SSH pela primeira vez é solicitado que você aceite o fingerprint
#       da máquina em que vc está conectando, esse fingerprint então é salvo no arquivo 
#       ".ssh/known_hosts" do seu usuário e, nas próximas conexões, não é mais solicitada essa
#       confirmação
#     - utilizei o parâmetro "StrictHostKeyChecking=no" para que não seja necessário responder
#       com "yes" para aceitar o fingerprint, não havendo necessidade de interação do usuário
#       Obs.: o MPI faz um SSH do master nos slaves, portanto, se esse procedimento não fosse
#             feito nesse momento, haveria a necessidade de aceitarmos o fingerprint do SSH
#             na primeira execução do MPI.
#             Outra possibilidade seria mudar as configurações do próprio MPI para conectar nos
#             slaves solicitar aceitação do fingerprint do SSH, porém, a ideia desse ambiente é
#             deixar o MPI em sua configuração padrão.
#
# 8 - testa o funcionamento do MPI no ambiente LXC
#     - o master (máquina Linux) conecta nos slaves (containers) e executa o comando "hostname"
#       no Linux dos containers. O resultado é o print dos nomes das instâncias LXC na tela
#       ex.: mpi2
#            mpi3
#            mpi4 ...
#########################################################################################

num_container_total=$1
num_container_total=$((num_container_total+2))
container=2
ip=2

#########################################################################################
# Etapa 1

if [ $# -lt 1 ]; then
  echo
  echo "Faltou utilizar pelo menos um argumento!"
  echo "ex.: sudo ./criar_containers_lxd.sh 3"
  echo "esse comando criará 3 instâncias de containers LXC"
  echo
  exit 1
fi

#########################################################################################
# Etapa 2

if [ "$EUID" != "0" ]; then
  echo
  echo "Utilize o sudo para executar o script"
  echo "ex.: sudo ./criar_containers_lxd.sh 3"
  echo "esse comando criará 3 instâncias de containers LXC"
  echo
  exit 1
fi

#########################################################################################
# Etapa 3

echo
echo "Excluindo possíveis containers que já estejam instanciados em sua máquina ..."

rm /home/mpi/mpi_host.db

cd /var/lib/lxd/containers/

for container_zumbi in mpi*
do
  lxc delete $container_zumbi --force
done

#########################################################################################
# Etapa 4

echo
echo "Criando os novos containers que serão utilizados como slave no MPI ..."

while [ $container -lt $num_container_total ]
do
  lxc launch mpi mpi$container
  ((container++ ))
done

sleep 3

#########################################################################################
# Etapa 5

echo
echo "Configurando IP nos containers ..."

container=2

while [ $container -lt $num_container_total ]
do
  lxc exec mpi$container -- ifconfig eth0 10.159.41.$ip/24
  echo "container mpi"$container" - IP 10.159.41."$ip"/24"
  ((container++))
  ((ip++))
done

#########################################################################################
# Etapa 6

sleep 3

echo
echo "Criando arquivo mpi_host.db - contém os IPs dos containers (MPI slaves)"

container=2
ip=2

while [ $container -lt $num_container_total ]
do
  echo "10.159.41."$ip >> /home/mpi/mpi_host.db
  ((container++))
  ((ip++))
done

#########################################################################################
# Etapa 7

sleep 3

echo
echo "Salvando as chaves SSH dos slaves no master para posterior conexão SSH no MPI"
echo 

container=2

rm /home/mpi/.ssh/known_hosts

while [ $container -lt $num_container_total ]
do
  su -c "ssh -o StrictHostKeyChecking=no mpi@10.159.41.$container &" -s /bin/bash mpi
  lxc exec mpi$container -- pkill -9 sshd
  ((container++))
  ((ip++))
done  

#########################################################################################
# Etapa 8

sleep 3

echo
echo "TESTANDO O MPI - conecta em todos os slaves e executa o comando HOSTNAME no Linux."
echo "retornará o nome das instâncias slave do MPI na tela"

for host in `cat /home/mpi/mpi_host.db`
do 
  su -c "mpirun -np 1 -host $host hostname" -s /bin/bash mpi
done
echo

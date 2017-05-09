#!/bin/bash

#########################################################################################
# OBSERVAÇÕES IMPORTANTES
#
# - este script não tem o objetivo de ser um exemplo de ótima programação. Tem por objetivo
#   ser simples e de fácil entendimento a qualquer computólogo
#
#########################################################################################

#########################################################################################
# O QUE ESSE SCRIPT FAZ?
#
# Etapas:
#
# 1 - verifica se o usuário informou o nome da aplicação
# 
# 2 - envia a aplicação aos containers (slaves MPI)
#########################################################################################

aplicacao=$1

#########################################################################################
# Etapa 1

if [ $# -lt 1 ]; then
  echo
  echo "Faltou informar o nome da aplicação!"
  echo "ex.: ./rodar_aplicacao_mpi.sh hello-world"
  echo "onde hello-world é o nome da aplicação MPI que você deseja executar"
  echo
  exit 1
fi

#######################################################################################
# Etapa 2

echo
echo "Enviando a aplicação MPI para os slaves MPI (containers LXD)"
echo
echo "copiado para:"
for host in `cat /home/mpi/mpi_host.db`
do 
  sudo su -c "scp $aplicacao $host:/home/mpi" -s /bin/bash mpi
  echo $host
done

######################################################################################
# Etapa 3

echo
echo "Rodando a aplicação ..."
echo
echo "não implementado ainda. Rode o comando mpirun manualmente"
echo
echo "Ex.: mpirun -np 10 -mca btl ^openib -hostfile mpi_host.db hello"
echo

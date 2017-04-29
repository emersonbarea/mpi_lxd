#!/bin/bash

if [ "$EUID" != "0" ]; then
  echo "Você deve ser root para rodar este script!"
  exit 1
fi

echo "Limpando todos containers ..."

rm /home/mpi/mpi_host.db

cd /var/lib/lxd/containers/

for container in mpi*
do
  lxc delete $container --force
done

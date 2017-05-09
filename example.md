## Compilando um programa exemplo

Para compilar e executar o programa exemplo, siga os passos abaixo:

1 - Compile o programa **hello world**: `mpicc -o hello MPI_Programs/hello_world/hello.c`

2 - envie uma cópia do programa **hello world** compilado aos slaves MPI: `./rodar_aplicacao_mpi.sh hello`

3 - execute o programa MPI seguindo a sugestão de comando para execuçãO: `mpirun -np 10 -mca btl ^openib -hostfile mpi_host.db hello`

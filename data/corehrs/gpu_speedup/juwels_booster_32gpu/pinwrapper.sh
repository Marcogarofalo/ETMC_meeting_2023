#!/bin/bash

if [ $SLURM_LOCALID = "0" ]
then
    NUMA=3,2
    MLX=mlx5_0:1
    GPU=0
fi
if [ $SLURM_LOCALID = "1" ]
then
    NUMA=1,0
    MLX=mlx5_1:1
    GPU=1
fi
if [ $SLURM_LOCALID = "2" ]
then
    NUMA=7,6
    MLX=mlx5_2:1
    GPU=2
fi
if [ $SLURM_LOCALID = "3" ]
then
    NUMA=5,4
    MLX=mlx5_3:1
    GPU=3
fi

allargs=( ${@} )
argmaxidx=$(( ${#allargs[@]} - 1 ))
exe="${1}"
args=${allargs[@]:1:${argmaxidx}}

echo allargs="${@}"
echo exe=$exe
echo args=${args[@]}

export NVSHMEM_ENABLE_NIC_PE_MAPPING=1
export NVSHMEM_HCA_LIST=$MLX

CMD="env UCX_NET_DEVICES=$MLX numactl --cpunodebind=$NUMA --membind=$NUMA -- $exe ${args[@]}"
echo $CMD
$CMD

#!/bin/bash -l
#SBATCH --account=pr74yo
#SBATCH --job-name=cB211.072.64_mshift_single_half
#SBATCH --nodes=8
#SBATCH --exclusive
#SBATCH --partition=booster
#SBATCH --gres=gpu:4
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=24
#SBATCH --time=03:30:00
#SBATCH --output=logs/log_%x_%j.out
#SBATCH --error=logs/log_%x_%j.err

echo "Report: Slurm Configuration"
echo "Job ID: ${SLURM_JOBID}"
echo "Node list: ${SLURM_JOB_NODELIST}"
echo "Node cabinets and electric groups"
scontrol show nodes ${SLURM_JOB_NODELIST} | grep -i activefeatures | sort -u

bdir=/p/home/jusers/kostrzewa2/juwels/build/juwelsbooster/stage_2022/gcc_11_2_0/openmpi_4_1_2
exe=${bdir}/tmLQCD.quda_work_add_actions-6284847f-quda-develop-bbf27d48/hmc_tm

source ${bdir}/load_modules.sh
module list

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${bdir}/quda-develop-bbf27d48/install_dir/lib

export CUDA_DEVICE_MAX_CONNECTIONS=1
export QUDA_ENABLE_TUNING=1
export QUDA_TUNE_VERSION_CHECK=0
export QUDA_REORDER_LOCATION=GPU
export QUDA_ENABLE_GDR=1
export QUDA_RESOURCE_PATH=$(pwd)
ulimit -c 0

echo `date`

export OMP_NUM_THREADS=24
export OMP_PROC_BIND=true
export OMP_PLACES=threads

echo 1 1 conf.start > nstore_counter

echo '# multishift single-half' >> output.data 

export CUDA_VISIBLE_DEVICES=0,1,2,3
srun --cpu-bind=none ./pinwrapper.sh ${exe} -f hmc_8n_4ppn_24tpt_cB211.072.64_mshift_single_half.input


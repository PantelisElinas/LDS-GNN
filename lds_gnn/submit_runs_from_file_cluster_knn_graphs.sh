#!/bin/bash
#SBATCH --time=04:00:00
#SBATCH --mem=8GB
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:1
#SBATCH --error=/scratch1/bon136/slurm-%A_%a.err
#SBATCH --output=/scratch1/bon136/slurm-%A_%a.out
#
# Submit runs from a file with each run per line
#
# submit many jobs as an array of jobs
# use e.g. sbatch -a 0-999 experiments/submit_runs_from_file_cluster_knn_graphs.sh
# where 0-999 are the range of the indices of the jobs
#
module load tensorflow/1.12.0-py36-gpu
module load cuda/10.0.130


IFS=$'\n' read -d '' -r -a lines < ${1}

# Submit job
if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
then
    i=$SLURM_ARRAY_TASK_ID
    echo ${lines[i]}
    eval "${lines[i]}"
else
    echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi




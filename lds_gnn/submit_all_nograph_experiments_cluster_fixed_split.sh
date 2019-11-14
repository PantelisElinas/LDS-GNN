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
# Submit no graph experiments to cluster (a feature-based prior is constructed )
#
# submit many jobs as an array of jobs
# use e.g. sbatch -a 0-999 submit_all_noisy_experiments_bracewell.sh
# where 0-999 are the range of the indices of the jobs
#
module load tensorflow/1.12.0-py36-gpu
module load cuda/9.0.176


# example
#  python lds.py -m knnlds -d cora -odir results -s 1 -splittrain True


RUN_FILE='lds.py'
ADD_VAL=0 # Add 50% validation set to training?
all_dataset_name='cora citeseer'
all_model='LDS-GNN'

if [ "$ADD_VAL" = "1" ]; then
    all_seed_val='1 10 2 20 3 30 4 40 5 50'
else
    all_seed_val='1 2 3 4 5 6 7 8 9 10'
fi


RESULTS_DIR=$SCRATCH1DIR'/'$all_model'/fixed_splits' # output for all results

# Creates all the experiments settings into a single big array
c=0
for seed_val in ${all_seed_val}
do
    for dataset_name in ${all_dataset_name}
    do
        for model in ${all_model}
        do
            ptr_dataset_name[c]=$dataset_name
            ptr_model[c]=$model
            ptr_seed_val[c]=$seed_val
            let c=c+1
        done
    done
done



# Submit job
if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
then
    i=$SLURM_ARRAY_TASK_ID
    DATASET_NAME=${ptr_dataset_name[$i]}
    MODEL=${ptr_model[$i]}
    SEED_VAL=${ptr_seed_val[$i]}

    str_options='-m knnlds -d '$DATASET_NAME' -s '$SEED_VAL


    if [ "$ADD_VAL" = "1" ]; then
        str_options=$str_options' -splittrain False'
    else
        str_options=$str_options' -splittrain True'
    fi

    name=$DATASET_NAME'/'$MODEL'/nograph''/v'$SEED_VAL
    RESULTS_DIR=$RESULTS_DIR'/'$name
    mkdir -p $RESULTS_DIR
    str_options=$str_options' -odir '$RESULTS_DIR
    echo $str_options

    PYTHONPATH=. python $RUN_FILE $str_options

else
    echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi




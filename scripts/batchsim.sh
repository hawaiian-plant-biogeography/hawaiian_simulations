#!/usr/bin/env sh

# Set up volumes
LSF_DOCKER_VOLUMES="/storage1/fs1/michael.landis/Active/hawaiian_simulations:/storage1/fs1/michael.landis/Active/hawaiian_simulations"
JOBDIR="/storage1/fs1/michael.landis/Active/hawaiian_simulations/joblogs"

# analysis settings
MIN_TAXA=20
MAX_TAXA=50
MIN_AGE=1
MAX_AGE=20

START_IDX=1
END_IDX=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
    START_IDX=1
    END_IDX=$1 
fi

if [ -n "$1" ] && [ -n "$2" ]; then
    START_IDX=$1
    END_IDX=$2
fi

echo "Running jobs ${START_IDX} to ${END_IDX}"

# get user/group for job submission
RUN_GROUP=${USER}

# Create a list of sims to run (numbers)
RUN_LIST=$(seq $START_IDX $END_IDX)

rm /storage1/fs1/michael.landis/Active/hawaiian_simulations_param/experiment1/pj_output/*.*
rm /storage1/fs1/michael.landis/Active/hawaiian_simulations_param/experiment1/pj_output/figures/*.*
rm /storage1/fs1/michael.landis/Active/hawaiian_simulations_param/experiment1/pj_scripts/*.*
rm /storage1/fs1/michael.landis/Active/hawaiian_simulations_param/experiment1/geosse_rates_for_pj_scripts/*.*
rm /storage1/fs1/michael.landis/Active/hawaiian_simulations_param/experiment1/pj_scripts_generated_in_py/*.*
rm /storage1/fs1/michael.landis/Active/hawaiian_simulations_param/experiment1/sim_data/*.*
rm /storage1/fs1/michael.landis/Active/hawaiian_simulations_param/experiment1/model_truth/*.*

# Create and run a job for each sim
for i in ${RUN_LIST[@]}
do
    echo "Submitting job ${i}"
    rm $JOBDIR/$i.sim.stdout.txt 
    bsub -G compute-michael.landis \
	-g /${RUN_GROUP} \
	-cwd /storage1/fs1/michael.landis/Active/hawaiian_simulations_param/ \
	-o $JOBDIR/$i.sim.stdout.txt \
	-J SIM_${i} \
	-q general \
	-n 4 -M 4GB -R "rusage [mem=4GB] span[hosts=1]" \
	-a 'docker(sswiston/phylo_docker:full_amd64)' /bin/bash /storage1/fs1/michael.landis/Active/hawaiian_simulations_param/scripts/sim_one.sh ${i} ${MIN_AGE} ${MAX_AGE} ${MIN_TAXA} ${MAX_TAXA}
done

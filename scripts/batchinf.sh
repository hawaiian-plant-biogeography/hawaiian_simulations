# Set up volumes
LSF_DOCKER_VOLUMES="/storage1/fs1/michael.landis/Active/hawaiian_simulations:/storage1/fs1/michael.landis/Active/hawaiian_simulations"
JOBDIR="/storage1/fs1/michael.landis/Active/hawaiian_simulations/joblogs"

# Create a list of sims to run (numbers)
START_IDX=$1
END_IDX=$2
RUN_LIST=$(seq $START_IDX $END_IDX)
#RUN_LIST=(9999)

# Create and run a job for each sim
for i in ${RUN_LIST[@]}
do
    bsub -G compute-michael.landis \
	-g /michael.landis \
	-cwd /storage1/fs1/michael.landis/Active/hawaiian_simulations/ \
	-o $JOBDIR/$i.inf.stdout.txt \
	-J $i \
	-q general \
	-n 8 -M 16GB -R "rusage [mem=16GB] span[hosts=1]" \
	-a 'docker(sswiston/rb_tp:pj)' /bin/bash /storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/inf_one.sh
done

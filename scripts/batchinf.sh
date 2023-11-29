# Set up volumes
LSF_DOCKER_VOLUMES="/storage1/fs1/michael.landis/Active/hawaiian_simulations:/storage1/fs1/michael.landis/Active/hawaiian_simulations"
JOBDIR="/storage1/fs1/michael.landis/Active/hawaiian_simulations/joblogs"

# Create a list of sims to run (numbers)
#RUN_LIST=$(seq 101 200)
RUN_LIST=(101)

# Create and run a job for each sim
for i in ${RUN_LIST[@]}
do
    bsub -G compute-michael.landis \
	-g /k.swiston/sim \
	-cwd /storage1/fs1/michael.landis/Active/hawaiian_simulations/ \
	-o $JOBDIR/$i.inf.stdout.txt \
	-J $i \
	-q general \
	-n 8 -M 16GB -R "rusage [mem=16GB] span[hosts=1]" \
	-a 'docker(sswiston/rb_tp:pj)' /bin/bash /storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/inf.sh
done

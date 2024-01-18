# Set up volumes
LSF_DOCKER_VOLUMES="/storage1/fs1/michael.landis/Active/hawaiian_simulations:/storage1/fs1/michael.landis/Active/hawaiian_simulations"
JOBDIR="/storage1/fs1/michael.landis/Active/hawaiian_simulations/joblogs"

# Create a list of sims to run (numbers)
RUN_LIST=$(seq 501 1000)
#RUN_LIST=(9999)

# Create and run a job for each sim
for i in ${RUN_LIST[@]}
do
    bsub -G compute-michael.landis \
	-g /k.swiston/sim \
	-cwd /storage1/fs1/michael.landis/Active/hawaiian_simulations/ \
	-o $JOBDIR/$i.stdout.txt \
	-J $i \
	-q general \
	-n 8 -M 8GB -R "rusage [mem=8GB] span[hosts=1]" \
	-a 'docker(sswiston/rb_tp:pj)' /bin/bash /storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/sim.sh
done

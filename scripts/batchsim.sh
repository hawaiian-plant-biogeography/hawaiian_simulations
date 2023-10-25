# Set up volumes
LSF_DOCKER_VOLUMES="/storage1/fs1/michael.landis/Active/hawaiian_simulations:/storage1/fs1/michael.landis/Active/hawaiian_simulations"
JOBDIR="/storage1/fs1/michael.landis/Active/hawaiian_simulations/joblogs"

# Create a list of sims to run (numbers)
RUN_LIST=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)

# Create and run a job for each sim
for i in ${RUN_LIST[@]}
do
    bsub -G compute-michael.landis \
	-g /k.swiston/sim \
	-cwd /storage1/fs1/michael.landis/Active/hawaiian_simulations/ \
	-o $JOBDIR/$i.stdout.txt \
	-J $i \
	-q general \
	-n 3 -M 15GB -R "rusage [mem=15GB] span[hosts=1]" \
	-a 'docker(sswiston/rb_tp:pj_test)' /bin/bash /storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/sim.sh
done

# Set up volumes
LSF_DOCKER_VOLUMES="/storage1/fs1/michael.landis/Active/hawaiian_simulations:/storage1/fs1/michael.landis/Active/hawaiian_simulations"
JOBDIR="/storage1/fs1/michael.landis/Active/hawaiian_simulations/joblogs"

# Create a list of sims to run (numbers)
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

# get user/group for job submission
RUN_GROUP=${USER}

# Create a list of infs to run (numbers)
RUN_LIST=$(seq $START_IDX $END_IDX)

# Create and run a job for each sim
for i in ${RUN_LIST[@]}
do
    bsub -G compute-michael.landis \
	-g /${RUN_GROUP} \
	-cwd /storage1/fs1/michael.landis/Active/hawaiian_simulations/ \
	-o $JOBDIR/$i.inf.stdout.txt \
	-J $i \
	-q general \
	-n 8 -M 16GB -R "rusage [mem=16GB] span[hosts=1]" \
	-a 'docker(sswiston/phylo_docker:basic_amd64)' /bin/bash /storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/inf_one.sh
done

# Set up volumes
LSF_DOCKER_VOLUMES="/storage1/fs1/michael.landis/Active/hawaiian_simulations:/storage1/fs1/michael.landis/Active/hawaiian_simulations"
JOBDIR="/storage1/fs1/michael.landis/Active/hawaiian_simulations/joblogs"

# Create a list of sims to run (numbers)
#RUN_LIST=$(seq 101 200)
RUN_LIST=(103 104 105 106 107 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 177 178 179 180 181 182 183 184 185 186 187 188 189 195 196 197)

# Create and run a job for each sim
for i in ${RUN_LIST[@]}
do
    bsub -G compute-michael.landis \
	-g /k.swiston/sim \
	-cwd /storage1/fs1/michael.landis/Active/hawaiian_simulations/ \
	-o $JOBDIR/$i.stdout.txt \
	-J $i \
	-q general \
	-n 8 -M 16GB -R "rusage [mem=16GB] span[hosts=1]" \
	-a 'docker(sswiston/rb_tp:pj)' /bin/bash /storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/sim.sh
done

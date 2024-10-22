# Run startup script that sets path variables
RB_EXEC="rb"

# check if running inside Docker
if [ -f "/start.sh" ]; then
    echo "Setting up Docker container"
    RB_EXEC="rb"
    source /start.sh
fi

# pass random sim/seed index as argument
S_IDX=1
if [ -n "${S_IDX}" ]; then
    S_IDX=$1
fi
if [ -n "${LSB_JOBNAME}" ]; then
    S_IDX=${LSB_JOBNAME}
fi

# Recording date and time of inference
echo "Performing inference $S_IDX"
NOW=$( date '+%F_%H:%M:%S' )
echo $NOW

# Run .Rev script to do inference on the simulation s_idx
echo "Running inference script"
RB_CMD="s_idx=${S_IDX};exp_path=\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/\";source(\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/rev_scripts/inf.Rev\");"
echo ${RB_CMD} | ${RB_EXEC}

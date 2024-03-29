# Run startup script that sets path variables
echo "Setting up Docker container"
source /start.sh

# Recording date and time of inference
SIM=$LSB_JOBNAME
echo "Performing inference $SIM"
NOW=$( date '+%F_%H:%M:%S' )
echo $NOW

# Run .Rev script to do inference on the simulation s_idx
echo "Running inference script"
rb_command="s_idx=${SIM};exp_path=\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/\";source(\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/rev_scripts/inf.Rev\");"
echo $rb_command | rb

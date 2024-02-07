# Run startup script that sets path variables
echo "Setting up Docker container"
source /start.sh

# Recording date and time of simulation
SIM=$LSB_JOBNAME
echo "Performing simulation $SIM"
NOW=$( date '+%F_%H:%M:%S' )
echo $NOW

# Run .Rev script to generate the parameters for the simulation s_idx
echo "Generating model parameters"
rb_command="s_idx=${SIM};exp_path=\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/\";source(\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/rev_scripts/make_fig_make_geosse_rates_unif_coltime.Rev\");"
echo $rb_command | rb

# Run .py script to generate the simulation .pj script for s_idx
echo "Generating PhyloJunction script"
python3 /storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/make_pj.py ${SIM} /storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/geosse_rates_for_pj_scripts/ /storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/model_truth/ /storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/pj_scripts_generated_in_py/ 127 7 "17.750, 7.750, 6.000, 3.930, 2.100, 1.100"

# Run the .pj script to (possibly) generate a simulated tree
echo "Running PhyloJunction script"
PJFILE="/storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/pj_scripts_generated_in_py/sim$SIM.pj"
NAME="sample$SIM"
timeout 3m pjcli $PJFILE -d -r ${SIM} -o /storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/pj_output/ -f 'trs' -p $NAME

# Run the .Rev script to (possibly) generate simulated sequences
rb_command="i=${SIM};exp_path=\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/\";source(\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/rev_scripts/sim_sequences.Rev\");"
echo $rb_command | rb

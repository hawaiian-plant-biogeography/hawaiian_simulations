# Run startup script that sets path variables
echo "Setting up Docker container"
source /start.sh
#export PYTHONPATH=/PhyloJunction/src

#export OMP_NUM_THREADS=1

# Recording date and time of simulation
SIM=$LSB_JOBNAME
echo "Performing simulation $SIM"
NOW=$( date '+%F_%H:%M:%S' )
echo $NOW

# Run .Rev script to generate the simulation .pj script for s_idx
echo "Generating PhyloJunction script"
rb_command="s_idx=${SIM};exp_path=\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/\";source(\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/rev_scripts/make_fig_make_pj_exp1.Rev\");"
echo $rb_command | rb

# Run the .pj script to (possibly) generate a simulated tree
echo "Running PhyloJunction script"
PJFILE="/storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/pj_scripts/sim$SIM.pj"
NAME="sample$SIM"
timeout 3m pjcli $PJFILE -d -o /storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/pj_output/ -f 'trs' -p $NAME

# Run the .Rev script to (possibly) generate simulated sequences
rb_command="i=${SIM};exp_path=\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/experiment1/\";source(\"/storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/rev_scripts/sim_sequences.Rev\");"
echo $rb_command | rb

# Run startup script that sets path variables
#echo "Setting up Docker container"
#source /start.sh

# Recording date and time of simulation
SIM=101 #$LSB_JOBNAME
DO_INF=false
echo "Performing simulation $SIM"
#NOW=$( date '+%F_%H:%M:%S' )
#echo $NOW

# Run .Rev script to do inference on the simulation s_idx
echo "Generating PhyloJunction script"
rb_command="s_idx=${SIM};inf=${DO_INF};exp_path=\"./experiment1/\";source(\"./scripts/rev_scripts/make_fig_make_pj_exp1.Rev\");"
echo $rb_command | rb

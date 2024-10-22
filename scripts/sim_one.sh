#!/bin/sh

RB_EXEC="rb"

# check if running inside Docker
echo "Searching for start.sh"
#if [ -f "/storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/start.sh" ]; then
if [ -f "/start.sh" ]; then
    RB_EXEC="rb"
    #source /storage1/fs1/michael.landis/Active/hawaiian_simulations/scripts/start.sh
    source /start.sh
    echo "... found start.sh!"
    #echo $PATH
    #echo $(which rb)
    #echo $(which rb-tp)
    #echo $(ls /.local)
    #echo $(ls /.local/bin)
    #echo $(ls /)
fi

NOW=$( date '+%F_%H:%M:%S' )
echo $NOW

# pass random sim/seed index as argument
S_IDX=1
if [ -n "${S_IDX}" ]; then
    S_IDX=$1
fi
if [ -n "${LSB_JOBNAME}" ]; then
    S_IDX=${LSB_JOBNAME}
fi

rm "./experiment1/sim_data/sample${S_IDX}.*"
rm "./experiment1/sim_data/sample_complete${S_IDX}.*"
rm "./experiment1/geosse_rates_for_pj_scripts/clado${S_IDX}.txt"
rm "./experiment1/geosse_rates_for_pj_scripts/mu${S_IDX}.txt"
rm "./experiment1/geosse_rates_for_pj_scripts/trans${S_IDX}.txt"
rm "./experiment1/model_truth/*_sample${S_IDX}.*"
rm "./experiment1/model_truth/*_sample${S_IDX}_*"
rm "./experiment1/model_truth/*_sample${S_IDX}_*"
rm "./experiment1/pj_scripts_generated_in_py/sim${S_IDX}.pj"

# RevBayes: generate island radiation rates
echo "RevBayes: generate island radiation rates (${S_IDX})"
rb_bg_args="s_idx=${S_IDX}; source(\"./scripts/rev_scripts/make_fig_rate_output.Rev\")"
echo "${rb_bg_args}" | ${RB_EXEC}
#exit 1

# RevBayes: generate Phylojunction scripts
EPOCH_TIMES="20.5 11.5 6.15 4.135 2.55 1.20"
echo "RevBayes: generate Phylojunction scripts (${S_IDX})"
echo "python3 ./scripts/make_pj.py ${S_IDX} experiment1/geosse_rates_for_pj_scripts/ experiment1/model_truth/ experiment1/pj_scripts_generated_in_py/ 127 7 \"${EPOCH_TIMES}\""
python3 ./scripts/make_pj.py ${S_IDX} experiment1/geosse_rates_for_pj_scripts/ experiment1/model_truth/ experiment1/pj_scripts_generated_in_py/ 127 7 "${EPOCH_TIMES}"

#python -c 'import sys; print("\n".join(sys.path))'
#find / -name "*dendropy*"
#mkdir -p ./pj_venv
#python3 -m venv ./pj_venv
#. ./pj_venv/bin/activate
#python3 -m pip uninstall dendropy
#python3 -m pip install dendropy numpy pandas phylojunction

# Phylojunction: run simulation
echo "Phylojunction: simulate island radiation (${S_IDX})"
pjcli -d -p "sample${S_IDX}" -r ${S_IDX} -o "./experiment1/pj_output/" "./experiment1/pj_scripts_generated_in_py/sim${S_IDX}.pj" -f "trs"

# Python: graft outgroup on to PJ tree
echo "Python: graft outgroup on to PJ tree (${S_IDX})"
python3 ./scripts/graft.py ${S_IDX}

# RevBayes: generate sequence data and make final tree
echo "RevBayes: simulate sequence data and make final tree (${S_IDX})"
rb_molphy_args="i=${S_IDX};exp_path=\"./experiment1/\";source(\"./scripts/rev_scripts/sim_sequences2.Rev\");"
echo $rb_mol_phy_args
echo $rb_molphy_args | ${RB_EXEC}

# R: make plot with range states at tips
Rscript ./scripts/plot_tree.R ${S_IDX} 0
Rscript ./scripts/plot_tree.R ${S_IDX} 1

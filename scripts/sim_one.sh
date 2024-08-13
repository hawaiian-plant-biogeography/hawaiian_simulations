#!/bin/sh

RB_EXEC="rb-tp"

# check if running inside Docker
if [ -f "/start.sh" ]; then
    RB_EXEC="rb"
    source /start.sh
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

# RevBayes: generate island radiation rates
echo "RevBayes: generate island radiation rates (${S_IDX})"
rb_bg_args="s_idx=${S_IDX}; source(\"./scripts/rev_scripts/make_fig_rate_output.Rev\")"

echo "${rb_bg_args}" | ${RB_EXEC}

# RevBayes: generate Phylojunction scripts
echo "RevBayes: generate Phylojunction scripts (${S_IDX})"
echo "python3 ./scripts/make_pj.py ${S_IDX} experiment1/geosse_rates_for_pj_scripts/ experiment1/model_truth/ experiment1/pj_scripts_generated_in_py/ 127 7 \"17.750, 7.750, 6.000, 3.930, 2.100, 1.100\""
python3 ./scripts/make_pj.py ${S_IDX} experiment1/geosse_rates_for_pj_scripts/ experiment1/model_truth/ experiment1/pj_scripts_generated_in_py/ 127 7 "17.750, 7.750, 6.000, 3.930, 2.100, 1.100"

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
Rscript ./scripts/plot_tree.R ${S_IDX}

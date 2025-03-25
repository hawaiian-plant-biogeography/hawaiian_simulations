#!/bin/sh

# Arguments
# $1: simulation replicate index
# $2: min colonization age
# $3: max colonization age
# $4: min clade size
# $5: max clade size


# check if running inside Docker
RB_EXEC="rb"
echo "Searching for start.sh"
if [ -f "/start.sh" ]; then
    RB_EXEC="rb"
    source /start.sh
    echo "... found start.sh!"
fi

NOW=$( date '+%F_%H:%M:%S' )
echo $NOW

#########################
# handle user arguments #
#########################

# replicate index
S_IDX=$1
if [ -z "${S_IDX}" ]; then
    S_IDX=1
fi
#if [ -n "${LSB_JOBNAME}" ]; then
#    S_IDX=${LSB_JOBNAME}
#fi

# min/max colonization ages
MAX_CROWN_AGE=32
MIN_COL_AGE=$2
MAX_COL_AGE=$3
if [ -z "${MIN_COL_AGE}" ]; then
    MIN_COL_AGE=0
fi
if [ -z "${MAX_COL_AGE}" ]; then
    MAX_COL_AGE=${MAX_CROWN_AGE}
fi

# min/max clade sizes
MIN_TAXA=$4
MAX_TAXA=$5
if [ -z "${MIN_TAXA}" ]; then
    MIN_TAXA=20
fi
if [ -z "${MAX_TAXA}" ]; then
    MAX_TAXA=50
fi

echo "Simulation settings:"
echo "  S_IDX=${S_IDX}"
echo "  MIN_COL_AGE=${MIN_COL_AGE}"
echo "  MAX_COL_AGE=${MAX_COL_AGE}"
echo "  MAX_CROWN_AGE=${MAX_CROWN_AGE}"
echo "  MIN_TAXA=${MIN_TAXA}"
echo "  MAX_TAXA=${MAX_TAXA}"

##########################################
# remove old simulation files that exist #
##########################################

rm ./experiment1/sim_data/sample${S_IDX}.*
rm ./experiment1/sim_data/sample_complete${S_IDX}.*
rm ./experiment1/geosse_rates_for_pj_scripts/clado${S_IDX}.txt
rm ./experiment1/geosse_rates_for_pj_scripts/mu${S_IDX}.txt
rm ./experiment1/geosse_rates_for_pj_scripts/trans${S_IDX}.txt
rm ./experiment1/model_truth/*_sample${S_IDX}.*
rm ./experiment1/model_truth/*_sample${S_IDX}_*
rm ./experiment1/model_truth/*_sample${S_IDX}_*
rm ./experiment1/pj_scripts_generated_in_py/sim${S_IDX}.pj


###########################################
# RevBayes: get biogeographic rates, etc. #
###########################################

# RevBayes: generate island radiation rates
echo "RevBayes: generate island radiation rates (${S_IDX})"
rb_bg_args="s_idx=${S_IDX}; min_col_age=${MIN_COL_AGE}; max_col_age=${MAX_COL_AGE}; max_crown_age=${MAX_CROWN_AGE}; source(\"./scripts/rev_scripts/make_fig_rate_output.Rev\")"
echo "${rb_bg_args}" | ${RB_EXEC}


# RevBayes: generate Phylojunction scripts
EPOCH_TIMES="20.5,11.5,6.15,4.135,2.55,1.20"
echo "RevBayes: generate Phylojunction scripts (${S_IDX})"
echo "python3 ./scripts/make_pj.py ${S_IDX} experiment1/geosse_rates_for_pj_scripts/ experiment1/model_truth/ experiment1/pj_scripts_generated_in_py/ 127 7 \"${EPOCH_TIMES}\""
python3 ./scripts/make_pj.py ${S_IDX} experiment1/geosse_rates_for_pj_scripts/ experiment1/model_truth/ experiment1/pj_scripts_generated_in_py/ 127 7 "${EPOCH_TIMES}" "${MIN_TAXA}" "${MAX_TAXA}"



############################################
# PhyloJunction: simulate island radiation #
############################################

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

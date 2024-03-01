#!/bin/sh

# pass random sim/seed index as argument
S_IDX=$1
if [ -z "${S_IDX}" ]; then
    S_IDX=1
fi

echo "Generating RevBayes rates for Replicate ${S_IDX}"
rb_args="s_idx=${S_IDX}; source(\"./scripts/rev_scripts/make_fig_make_geosse_rates_unif_coltime.Rev\")"

echo "${rb_args}" | rb-tp

echo "Generating PhyloJunction scripts for Replicate ${S_IDX}"
echo "python3 ./scripts/make_pj.py ${S_IDX} experiment1/geosse_rates_for_pj_scripts/ experiment1/model_truth/ experiment1/pj_scripts_generated_in_py/ 127 7 \"17.750, 7.750, 6.000, 3.930, 2.100, 1.100\""
python3 ./scripts/make_pj.py ${S_IDX} experiment1/geosse_rates_for_pj_scripts/ experiment1/model_truth/ experiment1/pj_scripts_generated_in_py/ 127 7 "17.750, 7.750, 6.000, 3.930, 2.100, 1.100"

echo "Running PhyloJunction for Replicate ${S_IDX}"
pjcli -d -p "sample${S_IDX}" -r ${S_IDX} -o "./experiment1/pj_output/" "./experiment1/pj_scripts_generated_in_py/sim${S_IDX}.pj"

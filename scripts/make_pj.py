#!/usr/bin/python3

# run code from base directory of repostiory, e.g.
#
# $ python3 scripts/make_pj.py 1 experiment1/geosse_rates_for_pj_scripts/ experiment1/model_truth/ experiment1/pj_scripts_generated_in_py/ 127 7 "17.750, 7.750, 6.000, 3.930, 2.100, 1.100"

# libraries
import os
import sys
import ast
import re

# sys.argv[1]: simulation number (integer)
# sys.argv[2]: GeoSSE rates directory (contains input)
# sys.argv[3]: Origin age and state directory (contains input)
# sys.argv[4]: pj script output directory (must exist)
# sys.argv[5]: number of states
# sys.argv[6]: number of epochs
# sys.argv[7]: epoch age ends

sim_idx = sys.argv[1]
rates_fp = sys.argv[2]
ori_fp = sys.argv[3]
ori_fn = ori_fp + "colonization_true_vals_sample" + sim_idx + ".tsv"
fp = sys.argv[4]
n_states = sys.argv[5]
n_epochs = sys.argv[6]
epoch_age_ends = sys.argv[7].rstrip("'").lstrip("'")

try:
    int(sim_idx)

except:
    exit(sys.argv[0] + ": Could not read simulation number (first argument) as integer.")

try:
    int(n_states)

except:
    exit(sys.argv[0] + ": Could not read number of states (fifth argument) as integer.")

try:
    int(n_epochs)

except:
    exit(sys.argv[0] + ": Could not read number of epochs (sixth argument) as integer.")

if len(epoch_age_ends.split(",")) != (int(n_epochs)-1):
    exit(sys.argv[0] + ": Number of epoch age ends must be the number of epochs minus 1.")

if not os.path.isdir(rates_fp):
    exit(sys.argv[0] + ": Directory containing GeoSSE rate files does not exist.")

if not os.path.isdir(ori_fp):
    print(ori_fp)
    exit(sys.argv[0] + ": Directory containing true origin ages and states does not exist.")

if not os.path.isfile(ori_fn):
    exit(sys.argv[0] + ": File containing origin age and state does not exist.")

if not os.path.isdir(fp):
    exit(sys.argv[0] + ": Directory for placing .pj script does not exist.")

# file paths and names
trans_fn = rates_fp + "trans" + sim_idx + ".txt"
ext_fn = rates_fp + "mu" + sim_idx + ".txt"
clado_fn = rates_fp + "clado" + sim_idx + ".txt"
out_fn = fp + "sim" + sim_idx + ".pj"

print("Everything OK with provided arguments!")
print("Preparing .pj script for simulation " + sim_idx + ".")

########################
# Preparing .pj string #
########################

# rate name container
rate_commands = list()
rate_names = list()

##############
# EXTINCTION #
##############

# det_death_rate0_t1 := sse_rate(name="mu_0_t2", value=2.53639, states=[0], event="extinction", epoch=1)
pj_death_template_str = 'det_death_rateSTATE_tEPOCH := sse_rate(name="mu_STATE_tEPOCH", value=VALUE, states=[STATE], event="extinction", epoch=EPOCH)'

# process extinction rates
ext_file = open(ext_fn, 'r')
for i,line in enumerate(ext_file.readlines()):

    # remove external brackets
    line = line[1:-2]
    line = line.replace('],', ']')
    line = line.replace(' ', '')
    toks = line.rstrip(']').split(']')

    for j,vec in enumerate(toks):
        # basic pj extinction template for epoch t
        epoch = str(j+1)
        vec = vec.strip('[]')
        toks2 = vec.split(',')

        for k,val in enumerate(toks2):
            # do something if val != 0
            if float(val) > 0:
                state = str(k)
                pj_death_str = pj_death_template_str.replace('STATE',state).replace('EPOCH',epoch).replace('VALUE',val)
                rate_commands.append( pj_death_str )
                rate_names.append( f'det_death_rate{state}_t{epoch}' )

ext_file.close()

##############
# TRANSITION #
##############

# det_trans_rate0_2_t0 := sse_rate(name="q0_2_t0", value=trans_rate0_2_t0, states=[0,2], event="transition", epoch=1)
pj_trans_template_str = 'det_trans_rateFROMSTATE_TOSTATE_tEPOCH := sse_rate(name="qFROMSTATE_TOSTATE_tEPOCH", value=VALUE, states=[FROMSTATE,TOSTATE], event="transition", epoch=EPOCH)'

# process transition rates
trans_file = open(trans_fn, 'r')
lines = ''.join(trans_file.readlines())
trans = ast.literal_eval(lines)

for i, x in enumerate(trans):
    epoch = str(i+1)

    for j,y in enumerate(x):
        from_state = str(j)

        for k,z in enumerate(y):
            to_state = str(k)
            val = str(z)

            if z > 0:
                pj_trans_str = pj_trans_template_str.replace('FROMSTATE', from_state).replace('TOSTATE', to_state).replace('EPOCH', epoch).replace('VALUE',val)
                rate_commands.append( pj_trans_str )
                rate_names.append( f'det_trans_rate{from_state}_{to_state}_t{epoch}' )

trans_file.close()


################
# CLADOGENETIC #
################

# det_w_birth_rate1_t1 := sse_rate(name="lambda1_t1", value=w_birth_rate1_t1, states=[1,1,1], event="w_speciation", epoch=2)
pj_clado_w_template_str = 'det_w_birth_rateANC_tEPOCH := sse_rate(name="lambdaANC_tEPOCH", value=VALUE, states=[ANC,ANC,ANC], event="w_speciation", epoch=EPOCH)'
#pj_clado_asym_template_str = 'det_b_birth_rateANC_LEFT_ANC_tEPOCH := sse_rate(name="lambdaANCLEFTANC_tEPOCH", value=b_birth_rateANC_LEFT_ANC_t1, states=[ANC,LEFT,ANC], event="asym_speciation", epoch=EPOCH)'
pj_clado_asym_template_str = 'det_b_birth_rateANC_LEFT_RIGHT_tEPOCH := sse_rate(name="lambdaANC_LEFT_RIGHT_tEPOCH", value=VALUE, states=[ANC,LEFT,RIGHT], event="asym_speciation", epoch=EPOCH)'
#pj_clado_bw_template_str = 'det_b_birth_rateANC_LEFT_RIGHT_tEPOCH := sse_rate(name="lambdaANCLEFTRIGHT_tEPOCH", value=b_birth_rateANC_LEFT_RIGHT_tEPOCH, states=[ANC,LEFT,RIGHT], event="bw_speciation", epoch=EPOCH)'
pj_clado_bw_template_str = 'det_b_birth_rateANC_LEFT_RIGHT_tEPOCH := sse_rate(name="lambdaANC_LEFT_RIGHT_tEPOCH", value=VALUE, states=[ANC,LEFT,RIGHT], event="bw_speciation", epoch=EPOCH)'

# process clado rates
clado_file = open(clado_fn, 'r')
lines = ''.join(clado_file.readlines())
lines = lines.replace(']\n, [',';')
toks = lines.split(';')
for i, clado_map in enumerate(toks):
    clado_map = clado_map.strip(' []')
    clado_events = clado_map.split(',\n')
    # epoch_for_name = str(i)
    epoch = str(i+1) # has to start at 1

    for k, evt in enumerate(clado_events):
        res = re.findall( r'[(] ([0-9]+) -> ([0-9]+), ([0-9]+) [)] = ([0-9]+[.][0-9]+)', evt)[0]
        anc_state, left_state, right_state, val = res

        if float(val) > 0.0:
            if anc_state == left_state and anc_state == right_state:
                pj_clado_str = pj_clado_w_template_str.replace('ANC', anc_state).replace("VALUE", val).replace('EPOCH', epoch)
                rate_commands.append( pj_clado_str )
                rate_names.append( f'det_w_birth_rate{anc_state}_t{epoch}' )

            elif anc_state != left_state and anc_state != right_state and int(left_state) < int(right_state):
                # only consider anc -> left,right patterns where left<right; ignore cases where right>left to avoid double-counting
                pj_clado_str = pj_clado_bw_template_str.replace('ANC', anc_state).replace('LEFT', left_state).replace('RIGHT', right_state).replace("VALUE",val).replace('EPOCH', epoch)

                rate_commands.append( pj_clado_str )
                rate_names.append( f'det_b_birth_rate{anc_state}_{left_state}_{right_state}_t{epoch}' )
                
            elif anc_state == right_state:
                # only consider anc -> left,anc patterns; skip anc -> anc,right patterns to avoid double-counting
                pj_clado_str = pj_clado_asym_template_str.replace('ANC', anc_state).replace('LEFT', left_state).replace('RIGHT',right_state).replace("VALUE",val).replace('EPOCH', epoch)
                rate_commands.append( pj_clado_str )
                rate_names.append( f'det_b_birth_rate{anc_state}_{left_state}_{right_state}_t{epoch}' )

clado_file.close()

########################
# ORIGIN AGE AND STATE #
########################

with open(ori_fn, "r") as ori_f:
    header, ori_info = ori_f.readlines()
    tokens = ori_info.split("\t")
    ori_age, ori_state = tokens[2:4]
    
sse_stash_str = '\nstash := sse_stash(flat_rate_mat=[ ' + ", ".join(rate_names) + ' ], ' + \
    'n_states=' + n_states + ', n_epochs=' + n_epochs + ', seed_age=' + ori_age + \
    ', epoch_age_ends=[' + epoch_age_ends + '])\n'

rate_commands.append(sse_stash_str)

trs_str = 'trs ~ discrete_sse(n=1, stash=stash, start_state=[' + ori_state + '], ' + \
    'stop="age", stop_value=' + ori_age + ', cond_surv="true", cond_obs_both_sides="false", ' + \
    'origin="true", min_rec_taxa=15, max_rec_taxa=200, abort_at_alive_count=5000)'

rate_commands.append(trs_str)

######################
# WRITING .pj SCRIPT #
######################

out_file = open(out_fn, 'w')
out_file.write( '\n'.join(rate_commands) )
out_file.close()

print('...done!')

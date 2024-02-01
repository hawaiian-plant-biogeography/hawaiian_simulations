#!/usr/bin/python3

import ast
import re

# file paths and names
fp = 'raw_test_output/'
trans_fn = fp + 'ana.txt'
ext_fn = fp + 'mu.txt'
clado_fn = fp + 'clado.txt'
out_fn = fp + 'out.pj'

# rate name container
rate_commands = []
rate_names = []

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
        epoch = str(j)
        vec = vec.strip('[]')
        toks2 = vec.split(',')

        for k,val in enumerate(toks2):
            # do something if val != 0
            if float(val) > 0:
                state = str(k)
                pj_death_str = pj_death_template_str.replace('STATE',state).replace('EPOCH',epoch).replace('VALUE',val)
                rate_commands.append( pj_death_str )
                rate_names.append( f'mu_{state}_t{epoch}' )

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

for i,x in enumerate(trans):
    epoch = str(i)
    for j,y in enumerate(x):
        from_state = str(j)
        for k,z in enumerate(y):
            to_state = str(k)
            val = str(z)
            if z > 0:
                pj_trans_str = pj_trans_template_str.replace('FROMSTATE', from_state).replace('TOSTATE', to_state).replace('EPOCH', epoch).replace('VALUE',val)
                rate_commands.append( pj_trans_str )
                rate_names.append( f'q{from_state}_{to_state}_t{epoch}' )
                # print(pj_trans_str)

trans_file.close()


################
# CLADOGENETIC #
################

# det_w_birth_rate1_t1 := sse_rate(name="lambda1_t1", value=w_birth_rate1_t1, states=[1,1,1], event="w_speciation", epoch=2)
pj_clado_w_template_str = 'det_w_birth_rateANC_tEPOCH := sse_rate(name="lambdaANC_tEPOCH", value=w_birth_rateANC_tEPOCH, states=[ANC,ANC,ANC], event="w_speciation", epoch=EPOCH)'
# det_b_birth_rate2_0_2_t1 := sse_rate(name="lambda202_t1", value=b_birth_rate2_0_2_t1, states=[2,0,2], event="asym_speciation", epoch=2)
pj_clado_asym_template_str = 'det_b_birth_rateANC_LEFT_ANC_tEPOCH := sse_rate(name="lambdaANCLEFTANC_tEPOCH", value=b_birth_rateANC_LEFT_ANC_t1, states=[ANC,LEFT,ANC], event="asym_speciation", epoch=EPOCH)'
# det_b_birth_rate2_0_1_t1 := sse_rate(name="lambda201_t1", value=b_birth_rate2_0_1_t1, states=[2,0,1], event="bw_speciation", epoch=2)
pj_clado_bw_template_str = 'det_b_birth_rateANC_LEFT_RIGHT_tEPOCH := sse_rate(name="lambdaANCLEFTRIGHT_tEPOCH", value=b_birth_rateANC_LEFT_RIGHT_tEPOCH, states=[ANC,LEFT,RIGHT], event="bw_speciation", epoch=EPOCH)'

# process clado rates
clado_file = open(clado_fn, 'r')
lines = ''.join(clado_file.readlines())
lines = lines.replace(']\n, [',';')
toks = lines.split(';')
for i,clado_map in enumerate(toks):
    clado_map = clado_map.strip(' []')
    clado_events = clado_map.split(',\n')
    epoch = str(i)
    for k,evt in enumerate(clado_events):
        res = re.findall( r'[(] ([0-9]+) -> ([0-9]+), ([0-9]+) [)] = ([0-9]+[.][0-9]+)', evt)[0]
        anc_state, left_state, right_state, val = res
        if float(val) > 0:
            if anc_state == left_state and anc_state == right_state:
                pj_clado_str = pj_clado_w_template_str.replace('ANC', anc_state).replace('EPOCH', epoch)
                rate_commands.append( pj_clado_str )
                rate_names.append( f'lambda{anc_state}_t{epoch}' )
            elif anc_state != left_state and anc_state != right_state:
                pj_clado_str = pj_clado_bw_template_str.replace('ANC', anc_state).replace('LEFT', left_state).replace('RIGHT', right_state).replace('EPOCH', epoch)
                rate_commands.append( pj_clado_str )
                rate_names.append( f'lambda{anc_state}{left_state}{anc_state}_t{epoch}' )
            else:
                pj_clado_str = pj_clado_asym_template_str.replace('ANC', anc_state).replace('LEFT', left_state).replace('EPOCH', epoch)
                rate_commands.append( pj_clado_str )
                rate_names.append( f'lambda{anc_state}{left_state}{right_state}_t{epoch}' )

clado_file.close()

# write commands to file
out_file = open(out_fn, 'w')
out_file.write( '\n'.join(rate_commands) )
out_file.close()

print('...done!')

import dendropy as dp
import pandas as pd
import sys
import os
import copy

idx                    = int(sys.argv[1])
exp_path               = './experiment1/'
continent_region_idx   = 6

pj_path                = exp_path + 'pj_output/'
model_path             = exp_path + 'model_truth/'
out_path               = exp_path + 'sim_data/'
tip_fn                 = pj_path + 'sample' + str(idx) + '_trs_sample1_repl1.tsv'
phy_fn                 = pj_path + 'sample' + str(idx) + '_trs_complete.tsv'
phy_ann_fn             = pj_path + 'sample' + str(idx) + '_trs_annotated_complete.tsv'
#tip_ann_fn             = pj_path + 'sample' + str(idx) + '_trs_sample1_repl1.tsv'
mdl_fn                 = model_path + 'colonization_true_vals_sample' + str(idx) + '.tsv'
out_prefix             = out_path + 'sample' + str(idx)
out_ann_prefix         = out_path + 'sample_complete' + str(idx)

def make_tree(phy_fn, out_prefix, drop_extinct=True):
    # quit if file missing
    phy_exists = os.path.exists(phy_fn)
    mdl_exists = os.path.exists(mdl_fn)
    if not phy_exists:
        print(f'ERROR: {phy_fn} not found.')
        quit()
    if not mdl_exists:
        print(f'ERROR: {mdl_fn} not found.')
        quit()

    # get Newick string
    phy_df = pd.read_csv(phy_fn, sep='\t')
    phy_str = phy_df['trs'].iloc[0]

    # get col strings
    col_df = pd.read_csv(mdl_fn, sep='\t')
    root_age = float(col_df['tree_age'].iloc[0])
    col_age = float(col_df['colonization_age'].iloc[0])

    # read tree
    phy = dp.Tree.get(data=phy_str, schema='newick')
    ingroup_node = phy.seed_node.child_nodes()[0]
    origin_time = float(ingroup_node.edge.length)
    ingroup_branch = root_age - col_age + origin_time

    print('Collect graft time data')
    print('  root_age = ', root_age, '; col_age = ', col_age, '; ori_time = ', origin_time, '; ingroup_branch = ', ingroup_branch)

    # graft outgroup
    ingroup_node.edge.length = ingroup_branch
    outgroup_node = dp.Node()
    outgroup_node.label = 'outgroup'
    outgroup_node.taxon = dp.Taxon(label='outgroup')
    outgroup_node.edge.length = root_age
    phy.seed_node.add_child(outgroup_node)
    print('Graft outgroup to tree')

    # prune non-extant taxa
    phy.resolve_node_ages()
    tol = 1e-9
    keep_taxa = []
    for nd in phy.leaf_nodes():
        if nd.age < tol:
            keep_taxa.append(nd.taxon)

    if drop_extinct:
        phy.retain_taxa(keep_taxa)
        print('Convert from complete to reconstructed tree')

    if drop_extinct:
        # update tip data
        df_tip = pd.read_csv(tip_fn, sep='\t', header=None)
        df_tip.loc[df_tip.shape[0]] = ['outgroup', continent_region_idx]
    if not drop_extinct:
        outgroup_node.annotations.add_new('state', str(continent_region_idx))
        tip_names = [ nd.taxon.label for nd in phy.leaf_nodes() ]
        tip_states = [ nd.annotations.get_value('state') for nd in phy.leaf_nodes() ]
        data = { 'name': tip_names, 'state': tip_states }
        df_tip = pd.DataFrame(data)
    print('Graft outgroup to states')

    # save new tree
    new_phy_fn = out_prefix + '.tre'
    phy.write(path=new_phy_fn, schema='newick')
    print('Write new tree to file: ', new_phy_fn)

    # save new tip data
    new_tip_fn = out_prefix + '.data.tsv'
    df_tip.to_csv(new_tip_fn, index=False, header=False, sep='\t')
    print('Write new states to file: ', new_tip_fn)
    return

make_tree(phy_fn, out_prefix, True)
make_tree(phy_ann_fn, out_ann_prefix, False)

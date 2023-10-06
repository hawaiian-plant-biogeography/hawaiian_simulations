# Experiment 1

**Pre-requisites**:

1. RevBayes as a running binary `rb`;
2. PhyloJunction's (PJ) interfaces as running binaries, `pjcli` and `pjgui`. Having PJ built in VS Code will be useful.

Both binaries above must be discoverable in the environmental PATH variable, inside `~/.bashrc` on Linux, or `~/.bash_profile` on Apple OS X.

**Goal**: Characterize accuracy and precision of parameter estimates (rho, sigma, phi, div times) as a function of:

* Tree size (number of taxa);
* Time-heterogeneity: (a) all islands always exist vs. appear in order, (b) features that are always the same vs. vary over time;
* Rho, sigma and phi values (on a grid or prior, to be decided).

## (1) Prepare PhyloJunction simulation scripts

In this step, we set up a FIG model in RevBayes and convert it into a time-heterogeneous GeoSSE model script for PhyloJunction.
Simultaneously, we will record the ``true'' parameter values for comparison later.
Each PJ script will generate a single (different) phylogenetic tree and other summary information.

Script:

* [`make_fig_make_pj_exp1.Rev`](https://github.com/hawaiian-plant-biogeography/hawaiian_simulations/blob/main/scripts/rev_scripts/make_fig_make_pj.Rev)

Running (root should be `hawaiian_simulations/`):

```
cd hawaiian_simulations/

rb scripts/rev_scripts/make_fig_make_pj_exp1.Rev
```

Note that this script will use the FIG model to sample an origin time for the island radiation and a starting biogeographic range (i.e., the ancestral state of the first island colonizer).

This script will place the files with true parameter values into `experiment1/model_truth/`, e.g.,

* [`rho_true_vals_sample1.tsv`]();
* [`sigma_true_vals_sample1_feat1.tsv`]();
* [`phi_true_vals_sample1_feat1.tsv`]().

The PJ script will go inside `experiment1/pj_scripts/`:

* `sim1.pj`.

### (1.1) Producing multiple PJ scripts in parallel

TODO


## (2) Running PhyloJunction

### (2.1) Inspecting things with the GUI

Loading a script on PJ's GUI is a good idea, as one can look at all the different DAG nodes the script creates.
To call the GUI, either open `pj_gui.py` on VS Code (`src/phylojunction/interface/pysidegui/`) and click 'Run Python File', or

```
pjgui
```

With the GUI open, on the top-left corner, do 'File > Read Script' and select the PJ script.
All created nodes (e.g., rates, probabilities, trees) will appear in the 'Model nodes' box.

### (2.2) Running a script with the CLI

In order to run PJ on the script produced in (1), we will call `pjcli` from the `experiment1` directory:

```
cd experiment1/

pjcli pj_scripts/sim1.pj -d -o pj_output/ -f 'trs' -p sample1
```

Here, `-d` tells PJ we want data output, `-o` specifies the output directory, and `-f` specifies we want a figure for the DAG node called `trs` (the island radiation phylogeny).

PhyloJunction will write the following files inside `pj_output`:

* `trs_annotated_complete.tsv`
* `trs_annotated_reconstructed.tsv`
* `trs_complete.tsv`
* `trs_reconstructed.tsv`
* `trs_sample1_repl1_anc_states.tsv`
* `trs_sample1_repl1.tsv`
* `trs_stats.csv`

and inside `pj_output/figures`:

* `trs_0_0.png`: a .png image of node "trs".

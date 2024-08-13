#!/usr/bin/env Rscript

library(ape)

args = commandArgs(trailingOnly=TRUE)
sim_idx = 5
if ( length(args) > 0 ) {
    sim_idx = args[1]
}

exp_dir = "./experiment1/sim_data/sample"
script_dir = "./scripts"

phy_fn = paste0(exp_dir, sim_idx, ".tre")
dat_fn = paste0(exp_dir, sim_idx, ".data.tsv")
lbl_fn = paste0(script_dir, "/range_label_n7.csv")
plot_fn = paste0(exp_dir, sim_idx, ".phy_dat.pdf")


phy = read.tree(phy_fn)
dat = read.table(dat_fn, sep="\t")
lbl = read.table(lbl_fn, sep=",", header=T, colClasses=c("numeric","character"))

region_names = unlist(strsplit("GNKOMHZ", split=""))

tip_ranges = list()
print(dat)
for (i in 1:length(phy$tip.label)) {
    tip_lbl = phy$tip.label[i]
    range_int = dat[dat$V1==tip_lbl,]$V2
    range_lbl = lbl[lbl$index == range_int,]$range
    regions_on = which( unlist(strsplit(range_lbl, split="")) == "1" )
    region_set = paste( region_names[regions_on], collapse="" )
    cat("Taxon=",i,
        "\trange_int=",range_int,
        "\trange_bit=", range_lbl,
        "\tregion_set=",region_set, "\n")
    
    tip_lbl = paste0( region_set, "  --  ", tip_lbl )
    phy$tip.label[i] = tip_lbl
}

pdf(file=plot_fn, height=12, width=12)
plot(phy)
dev.off()


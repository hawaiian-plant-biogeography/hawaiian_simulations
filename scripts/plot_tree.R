#!/usr/bin/env Rscript

library(ape)

args = commandArgs(trailingOnly=TRUE)
sim_idx = 2
if ( length(args) > 0 ) {
    sim_idx = args[1]
}

base_dir = "./experiment1/"
exp_dir = paste0(base_dir, "sim_data/sample")
col_dir = paste0(base_dir, "model_truth/colonization_true_vals_sample")
script_dir = "./scripts"

# filenames
phy_fn = paste0(exp_dir, sim_idx, ".tre")
dat_fn = paste0(exp_dir, sim_idx, ".data.tsv")
col_fn = paste0(col_dir, sim_idx, ".tsv")
lbl_fn = paste0(script_dir, "/range_label_n7.csv")
plot_fn = paste0(exp_dir, sim_idx, ".phy_dat.pdf")

# datasets
phy = read.tree(phy_fn)
dat = read.table(dat_fn, sep="\t", header=F)
colon = read.table(col_fn, sep="\t", header=T)
lbl = read.table(lbl_fn, sep=",", header=T, colClasses=c("numeric","character"))

region_names = unlist(strsplit("GNKOMHZ", split=""))

# phylo w/ biogeo info
tip_ranges = list()
#print(dat)
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
    phy = ladderize(phy, right=F)
}
num_taxa = length(phy$tip.label)

# event times
root_age = max(branching.times(phy))
epoch_times = root_age - c(17.750, 7.750, 6.000, 3.930, 2.100, 1.100, 0.000)
col_time = root_age - colon$colonization_age
col_region = colon$colonized_island_name
col_reg = region_names[colon$subroot_range+1]
col_age = round(colon$colonization_age, digits=2)

pdf(file=plot_fn, height=3+10*(num_taxa)/30, width=10)
#par(oma=c(0, 0, 0, 0))
#par(mar=c(0, 0, 0, 0))
plot(phy, x.lim=c(0,32))
axisPhylo(xlim=c(0,32))
abline(v=epoch_times, lty=2, col="blue")
abline(v=col_time, lty=1, col="red")
text(x=col_time*0, adj=0, y=num_taxa, labels=paste0("into ", col_reg, "\nage=", col_age), col="red", cex=0.75)
#text(x=col_time*0, adj=0, y=num_taxa-0.5, labels=paste0("age=", col_age), col="red", cex=0.75)
text(x=epoch_times, y=num_taxa, adj=c(1.2,0), labels=c("+N","","+K","+O","+M","+H",""), col="blue", cex=0.75)
dev.off()


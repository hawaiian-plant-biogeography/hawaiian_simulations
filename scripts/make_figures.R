# FIGURES EXAMINING COLONIZATION AGES WITH AND WITHOUT PALEOGEO
# SIMS 1-200 = WITH PALEOGEO
# SIMS 201-400 = WITHOUT PALEOGEO

# Packages
library(ggplot2)
library(ape)

# Getting Files
colonization_ages_path <- "../experiment1/model_truth"
trees_path <- "../experiment1/sim_data"
pattern <- "colonization_true_vals_sample*"
tree_pattern <- "*.tre"
files <- list.files(path=colonization_ages_path,pattern=pattern,full.names=TRUE)
treefiles <- list.files(path=trees_path,pattern=tree_pattern,full.names=TRUE)

# Getting Colonization Ages
sims <- c()
colonization_ages_paleo <- c()
colonization_ages_nopaleo <- c()
crown_ages_paleo <- c()
crown_ages_nopaleo <- c()

get_crown_age = function(treefile) {
    phy = read.tree(treefile)
    bt = sort(branching.times(phy))
    crown_age = rev(bt)[2]
    return(crown_age)
}

for (sim in 1:500) {
  file <- paste(colonization_ages_path, "/colonization_true_vals_sample", sim, ".tsv", sep="")
  treefile <- paste(trees_path, "/sample", sim ,".tre", sep="")
  if ((file %in% files) & (treefile %in% treefiles)) {
    data <- read.csv(file,sep="\t",header=TRUE)
    colonization_age <- data$colonization_age[1]
    colonization_ages_paleo <- c(colonization_ages_paleo, colonization_age)
    crown_ages_paleo <- c(crown_ages_paleo, get_crown_age(treefile))
    sims <- c(sims, sim)
  }
}
for (sim in 501:1000) {
  file <- paste(colonization_ages_path, "/colonization_true_vals_sample", sim, ".tsv", sep="")
  treefile <- paste(trees_path, "/sample", sim ,".tre", sep="")
  if ((file %in% files) & (treefile %in% treefiles)) {
    data <- read.csv(file,sep="\t",header=TRUE)
    colonization_age <- data$colonization_age[1]
    colonization_ages_nopaleo <- c(colonization_ages_nopaleo, colonization_age)
    crown_ages_nopaleo <- c(crown_ages_nopaleo, get_crown_age(treefile))
    sims <- c(sims, sim)
  }
}
colonization_ages_paleo
colonization_ages_nopaleo

paleo_df <- cbind(colonization_ages_paleo, crown_ages_paleo, rep("paleo",length(colonization_ages_paleo)))
nopaleo_df <- cbind(colonization_ages_nopaleo, crown_ages_nopaleo, rep("nopaleo",length(colonization_ages_nopaleo)))

df <- rbind(paleo_df,nopaleo_df)
df <- cbind(sims,df)
df <- data.frame(df)
colnames(df) <- c("sim","col_age","crown_age","geo")
df$col_age <- as.numeric(df$col_age)
df$crown_age <- as.numeric(df$crown_age)
df$diff_age <- df$col_age - df$crown_age 

# Plotting Colonization Ages
for (lbl in c("col_age","crown_age","diff_age")) {
    p = ggplot(df, aes_string(x=lbl,fill="geo")) +
      geom_density(bw=1.25,alpha=0.6) +
      scale_x_reverse(breaks=seq(0,30), expand=c(0,0)) +
      scale_y_continuous(limits=c(0,0.15), expand=c(0,0)) +
      scale_fill_manual(labels=c("No Paleo", "Paleo"),
                        values=c("salmon", "cyan3")) +
      geom_vline(xintercept=1.1) +
      geom_vline(xintercept=2.1) +
      geom_vline(xintercept=3.93) +
      geom_vline(xintercept=6) +
      geom_vline(xintercept=7.75) +
      geom_vline(xintercept=17.75) +
      labs(x=paste0(lbl, " (Ma)"),
           y="Density",
           fill="Geography") +
      theme_bw() +
      theme(aspect.ratio=1/2,
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank(),
            panel.grid.major.x=element_blank(),
            panel.grid.minor.x=element_blank(),
            panel.grid.major.y=element_blank(),
            panel.grid.minor.y=element_blank())

    plot_fn = paste0(lbl, ".pdf")
    pdf(plot_fn, height=7, width=7)
    print(p)
    dev.off()
}

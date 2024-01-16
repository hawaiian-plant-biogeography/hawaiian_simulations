# FIGURES EXAMINING COLONIZATION AGES WITH AND WITHOUT PALEOGEO
# SIMS 1-200 = WITH PALEOGEO
# SIMS 201-400 = WITHOUT PALEOGEO

# Packages
library(ggplot2)

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
for (sim in 1:200) {
  file <- paste(colonization_ages_path, "/colonization_true_vals_sample", sim, ".tsv", sep="")
  treefile <- paste(trees_path, "/sample", sim ,".tre", sep="")
  if ((file %in% files) & (treefile %in% treefiles)) {
    data <- read.csv(file,sep="\t",header=TRUE)
    colonization_age <- data$colonization_age[1]
    colonization_ages_paleo <- c(colonization_ages_paleo, colonization_age)
    sims <- c(sims, sim)
  }
}
for (sim in 201:400) {
  file <- paste(colonization_ages_path, "/colonization_true_vals_sample", sim, ".tsv", sep="")
  treefile <- paste(trees_path, "/sample", sim ,".tre", sep="")
  if ((file %in% files) & (treefile %in% treefiles)) {
    data <- read.csv(file,sep="\t",header=TRUE)
    colonization_age <- data$colonization_age[1]
    colonization_ages_nopaleo <- c(colonization_ages_nopaleo, colonization_age)
    sims <- c(sims, sim)
  }
}
colonization_ages_paleo
colonization_ages_nopaleo
paleo_df <- cbind(colonization_ages_paleo,rep("paleo",length(colonization_ages_paleo)))
nopaleo_df <- cbind(colonization_ages_nopaleo,rep("nopaleo",length(colonization_ages_nopaleo)))
df <- rbind(paleo_df,nopaleo_df)
df <- cbind(sims,df)
df <- data.frame(df)
colnames(df) <- c("sim","age","geo")
df$age <- as.numeric(df$age)

# Plotting Colonization Ages
ggplot(df, aes(x=age,fill=geo)) +
  geom_density(alpha=0.6) +
  scale_x_reverse(breaks=seq(15,30), expand=c(0,0)) +
  scale_y_continuous(limits=c(0,0.15), expand=c(0,0)) +
  scale_fill_manual(labels=c("No Paleo", "Paleo"),
                    values=c("salmon", "cyan3")) +
  labs(x="Colonization Age",
       y="Density",
       fill="Geography") +
  theme_bw() +
  theme(aspect.ratio=1/2,
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        panel.grid.minor.x=element_blank(),
        panel.grid.major.y=element_blank(),
        panel.grid.minor.y=element_blank())


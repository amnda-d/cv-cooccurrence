library(brms)
library(tidyverse)
library(bayesplot)
library(tidybayes)
library(rcartocolor)

setwd('~/McGill/projects/co-ocurrence-harmony')
data <- read.csv('data/r_data/northeuralex.csv')


# Figure 2: feature and natural class similarity distributions

data %>% ggplot(aes(x =sim)) +
  geom_density(alpha=0.4, fill="#88CCEE", color="#88CCEE") +
  geom_density(aes(x=nat_class_sim), fill="#CC6677", color="#CC6677", alpha=0.4) +
  xlab("Similarity") +
  ylab("Density") +
  theme(legend.position="none") +
  theme_light()

ggsave('r/figures/fig2.png', width=4, height=2, units='in')

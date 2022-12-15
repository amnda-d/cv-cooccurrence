library(brms)
library(ggplot2)
# library(tidyverse)

heb <- readRDS('~/McGill/projects/semitic-harmony/r/models/hebrew/model.rds')
ara <- readRDS('~/McGill/projects/semitic-harmony/r/models/arabic/model.rds')

plot(heb)
ggsave('~/McGill/projects/semitic-harmony/r/figures_new/plots_heb.pdf', width=8, height=8, units='in')

plot(ara)
ggsave('~/McGill/projects/semitic-harmony/r/figures_new/plots_ara.pdf', width=8, height=8, units='in')

library(brms)
library(tidyverse)
library(tidybayes)
library(bayestestR)

nc <- readRDS('r/models/5-3-non-adj-nc/model.rds')
fam_nc <- readRDS('r/models/5-4-non-adj-nc-family/model.rds')
feat <- readRDS('r/models/5-3-non-adj-feat/model.rds')
fam_feat <- readRDS('r/models/5-4-non-adj-feat-family/model.rds')

pd(nc, effects='all')
pd(feat, effects='all')
pd(fam_nc, effects='all')
pd(fam_feat, effects='all')

# Similarity
## sd(v sim fam) < sd(v sim lang)
hypothesis(fam_nc, "sd_family__paircountv_sim_new < sd_family:language__paircountv_sim_new", class=NULL)
hypothesis(fam_feat, "sd_family__paircountv_sim_new < sd_family:language__paircountv_sim_new", class=NULL)


## nc v. fam: sd(sim V) < sd(ident V)
hypothesis(nc, "sd_language__paircountv_sim_new < sd_language__paircountv_ident_new", class=NULL)
hypothesis(feat, "sd_language__paircountv_sim_new < sd_language__paircountv_ident_new", class=NULL)


# Identity
## sd(v ident lang) < sd(v ident fam)
hypothesis(fam_nc, "sd_family:language__paircountv_ident_new < sd_family__paircountv_ident_new", class=NULL)
hypothesis(fam_feat, "sd_family:language__paircountv_ident_new < sd_family__paircountv_ident_new", class=NULL)


## c sim < c ident (all models)
hypothesis(nc, "abs(b_paircount_sim_new) < abs(b_paircount_ident_new)", class=NULL)
hypothesis(feat, "abs(b_paircount_sim_new) < abs(b_paircount_ident_new)", class=NULL)
hypothesis(fam_nc, "abs(b_paircount_sim_new) < abs(b_paircount_ident_new)", class=NULL)
hypothesis(fam_feat, "abs(b_paircount_sim_new) < abs(b_paircount_ident_new)", class=NULL)

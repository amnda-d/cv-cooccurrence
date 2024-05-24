library(brms)
library(tidyverse)
library(tidybayes)

setwd('~/McGill/projects/co-ocurrence-harmony')

nc <- readRDS('r/models/5-4-non-adj-nc-family/model.rds')
feat <- readRDS('r/models/5-4-non-adj-feat-family/model.rds')

draws_nc <- nc %>% spread_draws(
  `r_family:language__paircount`[language, term],
  `r_family:language__paircountv`[language, term],
  b_paircount_sim_new,
  b_paircountv_sim_new,
  b_paircount_ident_new,
  b_paircountv_ident_new
)

draws_nc$`r_family_language__paircount` <- draws_nc$`r_family:language__paircount`
draws_nc$`r_family_language__paircountv` <- draws_nc$`r_family:language__paircountv`

draws_feat <- feat %>% spread_draws(
  `r_family:language__paircount`[language, term],
  `r_family:language__paircountv`[language, term],
  b_paircount_sim_new,
  b_paircountv_sim_new,
  b_paircount_ident_new,
  b_paircountv_ident_new
)

draws_feat$`r_family_language__paircount` <- draws_feat$`r_family:language__paircount`
draws_feat$`r_family_language__paircountv` <- draws_feat$`r_family:language__paircountv`

nc_sim_intervals <- draws_nc %>% subset(term=='sim_new') %>% 
  median_qi(
    sim_coef_c=r_family_language__paircount + b_paircount_sim_new,
    sim_coef_v=r_family_language__paircountv + b_paircountv_sim_new
  )

nc_ident_intervals <- draws_nc %>% subset(term=='ident_new') %>%
  median_qi(
    ident_coef_c=r_family_language__paircount + b_paircount_ident_new,
    ident_coef_v=r_family_language__paircountv + b_paircountv_ident_new
  )

feat_sim_intervals <- draws_nc %>% subset(term=='sim_new') %>% 
  median_qi(
    sim_coef_c=r_family_language__paircount + b_paircount_sim_new,
    sim_coef_v=r_family_language__paircountv + b_paircountv_sim_new
  )

feat_ident_intervals <- draws_nc %>% subset(term=='ident_new') %>%
  median_qi(
    ident_coef_c=r_family_language__paircount + b_paircount_ident_new,
    ident_coef_v=r_family_language__paircountv + b_paircountv_ident_new
  )

nc_c <- data.frame(
  familyLanguage = nc_sim_intervals$language,
  nc_sim = round(nc_sim_intervals$sim_coef_c, 3),
  nc_sim_credI = paste('[', round(nc_sim_intervals$sim_coef_c.lower, 3), ', ', round(nc_sim_intervals$sim_coef_c.upper, 3), ']'),
  nc_ident = round(nc_ident_intervals$ident_coef_c, 3),
  nc_ident_credI = paste('[', round(nc_ident_intervals$ident_coef_c.lower, 3), ', ', round(nc_ident_intervals$ident_coef_c.upper, 3), ']')
)

feat_c <- data.frame(
  familyLanguage = feat_sim_intervals$language,
  feat_sim = round(feat_sim_intervals$sim_coef_c, 3),
  feat_sim_credI = paste('[', round(feat_sim_intervals$sim_coef_c.lower, 3), ', ', round(feat_sim_intervals$sim_coef_c.upper, 3), ']'),
  feat_ident = round(feat_ident_intervals$ident_coef_c, 3),
  feat_ident_credI = paste('[', round(feat_ident_intervals$ident_coef_c.lower, 3), ', ', round(feat_ident_intervals$ident_coef_c.upper, 3), ']')
)

nc_v <- data.frame(
  familyLanguage = nc_sim_intervals$language,
  nc_sim = round(nc_sim_intervals$sim_coef_v, 3),
  nc_sim_credI = paste('[', round(nc_sim_intervals$sim_coef_v.lower, 3), ', ', round(nc_sim_intervals$sim_coef_v.upper, 3), ']'),
  nc_ident = round(nc_ident_intervals$ident_coef_v, 3),
  nc_ident_credI = paste('[', round(nc_ident_intervals$ident_coef_v.lower, 3), ', ', round(nc_ident_intervals$ident_coef_v.upper, 3), ']')
)

feat_v <- data.frame(
  familyLanguage = feat_sim_intervals$language,
  feat_sim = round(feat_sim_intervals$sim_coef_v, 3),
  feat_sim_credI = paste('[', round(feat_sim_intervals$sim_coef_v.lower, 3), ', ', round(feat_sim_intervals$sim_coef_v.upper, 3), ']'),
  feat_ident = round(feat_ident_intervals$ident_coef_v, 3),
  feat_ident_credI = paste('[', round(feat_ident_intervals$ident_coef_v.lower, 3), ', ', round(feat_ident_intervals$ident_coef_v.upper, 3), ']')
)

cons <- merge(nc_c, feat_c, by='familyLanguage')
vowels <- merge(nc_v, feat_v, by='familyLanguage')

write.table(vowels, sep='\t', file="r/language_vowel_effects.tsv", quote=F, row.names=F)
write.table(cons, sep='\t', file="r/language_consonant_effects.tsv", quote=F, row.names=F)

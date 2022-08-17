library(brms)
library(tidyverse)
library(tidybayes)
library(cowplot)

setwd('~/McGill/projects/co-ocurrence-harmony')

model <- readRDS('r/models/5-3-non-adj-nc/model.rds')

draws <- model %>% spread_draws(
  r_language__paircount[language, term],
  r_language__paircountv[language, term],
  b_paircount_sim_new,
  b_paircountv_sim_new,
  b_paircount_ident_new,
  b_paircountv_ident_new
)

draws$c_sim <- draws$r_language__paircount + draws$b_paircount_sim_new
draws$v_sim <- draws$r_language__paircountv + draws$b_paircountv_sim_new
draws$c_ident <- draws$r_language__paircount + draws$b_paircount_ident_new
draws$v_ident <- draws$r_language__paircountv + draws$b_paircountv_ident_new

sim_intervals <- draws %>% subset(term=='sim_new') %>% median_qi(sim_coef_c=r_language__paircount + b_paircount_sim_new, sim_coef_v=r_language__paircountv + b_paircountv_sim_new)
ident_intervals <- draws %>% subset(term=='ident_new') %>% median_qi(ident_coef_c=r_language__paircount + b_paircount_ident_new, ident_coef_v=r_language__paircountv + b_paircountv_ident_new)

sim_data <- draws %>% subset(term == 'sim_new')

p <- ggplot() +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.95, fill='#88CCEE', color='#88CCEE', geom='polygon') +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.75, fill='#DDCC77', color='#DDCC77', geom='polygon') +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.5, fill='#CC6677', color='#CC6677', geom='polygon') +
  geom_point(data=sim_intervals, aes(x=sim_coef_c, y=sim_coef_v)) +
  geom_smooth(data=sim_data %>% filter(.draw < 25), aes(x=c_sim, y=v_sim, group = .draw), method = "lm", se = F, size = 0.25, color='#3D3D3D') +
  geom_hline(aes(yintercept=0), lty=2, color='black') +
  geom_vline(aes(xintercept=0), lty=2, color='black') +
  labs(x="Consonant Similarity", y="Vowel Similarity") +
  theme_light()

y_margin <- axis_canvas(p, axis='y') + geom_density(data=sim_data, aes(y=v_sim), fill='#969696') + geom_hline(yintercept=mean(sim_data$v_sim))
x_margin <- axis_canvas(p, axis='x') + geom_density(data=sim_data, aes(x=c_sim), fill='#969696') + geom_vline(xintercept=mean(sim_data$c_sim))

combined_plot <- insert_yaxis_grob(p, y_margin, position = "right")
nc <- insert_xaxis_grob(combined_plot, x_margin, position = "top")

################################

model <- readRDS('r/models/5-3-non-adj-feat/model.rds')

draws <- model %>% spread_draws(
  r_language__paircount[language, term],
  r_language__paircountv[language, term],
  b_paircount_sim_new,
  b_paircountv_sim_new,
  b_paircount_ident_new,
  b_paircountv_ident_new
)

draws$c_sim <- draws$r_language__paircount + draws$b_paircount_sim_new
draws$v_sim <- draws$r_language__paircountv + draws$b_paircountv_sim_new
draws$c_ident <- draws$r_language__paircount + draws$b_paircount_ident_new
draws$v_ident <- draws$r_language__paircountv + draws$b_paircountv_ident_new

sim_intervals <- draws %>% subset(term=='sim_new') %>% median_qi(sim_coef_c=r_language__paircount + b_paircount_sim_new, sim_coef_v=r_language__paircountv + b_paircountv_sim_new)
ident_intervals <- draws %>% subset(term=='ident_new') %>% median_qi(ident_coef_c=r_language__paircount + b_paircount_ident_new, ident_coef_v=r_language__paircountv + b_paircountv_ident_new)

sim_data <- draws %>% subset(term == 'sim_new')

p <- ggplot() +
  xlim(-2.5, 1) +
  ylim(-0.4, 1) +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.95, fill='#88CCEE', color='#88CCEE', geom='polygon') +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.75, fill='#DDCC77', color='#DDCC77', geom='polygon') +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.5, fill='#CC6677', color='#CC6677', geom='polygon') +
  geom_point(data=sim_intervals, aes(x=sim_coef_c, y=sim_coef_v)) +
  geom_smooth(data=sim_data %>% filter(.draw < 25), aes(x=c_sim, y=v_sim, group = .draw), method = "lm", se = F, size = 0.25, color='#3D3D3D') +
  geom_hline(aes(yintercept=0), lty=2, color='black') +
  geom_vline(aes(xintercept=0), lty=2, color='black') +
  labs(x="Consonant Similarity", y="Vowel Similarity") +
  theme_light()

y_margin <- axis_canvas(p, axis='y') + geom_density(data=sim_data, aes(y=v_sim), fill='#969696') + geom_hline(yintercept=mean(sim_data$v_sim))
x_margin <- axis_canvas(p, axis='x') + geom_density(data=sim_data, aes(x=c_sim), fill='#969696') + geom_vline(xintercept=mean(sim_data$c_sim))

combined_plot <- insert_yaxis_grob(p, y_margin, position = "right")
feat <- insert_xaxis_grob(combined_plot, x_margin, position = "top")

########################

model <- readRDS('r/models/5-4-non-adj-nc-family/model.rds')

draws <- model %>% spread_draws(
  `r_family:language__paircount`[language, term],
  `r_family:language__paircountv`[language, term],
  b_paircount_sim_new,
  b_paircountv_sim_new,
  b_paircount_ident_new,
  b_paircountv_ident_new
)

draws$`r_family_language__paircount` <- draws$`r_family:language__paircount`
draws$`r_family_language__paircountv` <- draws$`r_family:language__paircountv`

draws$c_sim <- draws$`r_family:language__paircount` + draws$b_paircount_sim_new
draws$v_sim <- draws$`r_family:language__paircountv` + draws$b_paircountv_sim_new
draws$c_ident <- draws$`r_family:language__paircount` + draws$b_paircount_ident_new
draws$v_ident <- draws$`r_family:language__paircountv` + draws$b_paircountv_ident_new

sim_intervals <- draws %>% subset(term=='sim_new') %>% median_qi(sim_coef_c=r_family_language__paircount + b_paircount_sim_new, sim_coef_v=r_family_language__paircountv + b_paircountv_sim_new)
ident_intervals <- draws %>% subset(term=='ident_new') %>% median_qi(ident_coef_c=r_family_language__paircount + b_paircount_ident_new, ident_coef_v=r_family_language__paircountv + b_paircountv_ident_new)

sim_data <- draws %>% subset(term == 'sim_new')

p <- ggplot() +
  xlim(-2.5, 1) +
  ylim(-0.7, 1.6) +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.95, fill='#CC6677', color='#CC6677', geom='polygon') +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.75, fill='#DDCC77', color='#DDCC77', geom='polygon') +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.5, fill='#88CCEE', color='#88CCEE', geom='polygon') +
  geom_point(data=sim_intervals, aes(x=sim_coef_c, y=sim_coef_v)) +
  geom_smooth(data=sim_data %>% filter(.draw < 25), aes(x=c_sim, y=v_sim, group = .draw), method = "lm", se = F, size = 0.25, color='#3D3D3D') +
  geom_hline(aes(yintercept=0), lty=2, color='black') +
  geom_vline(aes(xintercept=0), lty=2, color='black') +
  labs(x="Consonant Similarity", y="Vowel Similarity") +
  theme_light()

y_margin <- axis_canvas(p, axis='y') + geom_density(data=sim_data, aes(y=v_sim), fill='#969696') + geom_hline(yintercept=mean(sim_data$v_sim))
x_margin <- axis_canvas(p, axis='x') + geom_density(data=sim_data, aes(x=c_sim), fill='#969696') + geom_vline(xintercept=mean(sim_data$c_sim))

combined_plot <- insert_yaxis_grob(p, y_margin, position = "right")
fam_nc <- insert_xaxis_grob(combined_plot, x_margin, position = "top")

#####################

model <- readRDS('r/models/5-4-non-adj-feat-family/model.rds')

draws <- model %>% spread_draws(
  `r_family:language__paircount`[language, term],
  `r_family:language__paircountv`[language, term],
  b_paircount_sim_new,
  b_paircountv_sim_new,
  b_paircount_ident_new,
  b_paircountv_ident_new
)

draws$`r_family_language__paircount` <- draws$`r_family:language__paircount`
draws$`r_family_language__paircountv` <- draws$`r_family:language__paircountv`

draws$c_sim <- draws$`r_family:language__paircount` + draws$b_paircount_sim_new
draws$v_sim <- draws$`r_family:language__paircountv` + draws$b_paircountv_sim_new
draws$c_ident <- draws$`r_family:language__paircount` + draws$b_paircount_ident_new
draws$v_ident <- draws$`r_family:language__paircountv` + draws$b_paircountv_ident_new

sim_intervals <- draws %>% subset(term=='sim_new') %>% median_qi(sim_coef_c=r_family_language__paircount + b_paircount_sim_new, sim_coef_v=r_family_language__paircountv + b_paircountv_sim_new)
ident_intervals <- draws %>% subset(term=='ident_new') %>% median_qi(ident_coef_c=r_family_language__paircount + b_paircount_ident_new, ident_coef_v=r_family_language__paircountv + b_paircountv_ident_new)

sim_data <- draws %>% subset(term == 'sim_new')

p <- ggplot() +
  xlim(-2.5, 1) +
  ylim(-0.7, 1.6) +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.95, fill='#CC6677', color='#CC6677', geom='polygon') +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.75, fill='#DDCC77', color='#DDCC77', geom='polygon') +
  stat_ellipse(data=sim_data, aes(x = c_sim, y = v_sim), level=0.5, fill='#88CCEE', color='#88CCEE', geom='polygon') +
  geom_point(data=sim_intervals, aes(x=sim_coef_c, y=sim_coef_v)) +
  geom_smooth(data=sim_data %>% filter(.draw < 25), aes(x=c_sim, y=v_sim, group = .draw), method = "lm", se = F, size = 0.25, color='#3D3D3D') +
  geom_hline(aes(yintercept=0), lty=2, color='black') +
  geom_vline(aes(xintercept=0), lty=2, color='black') +
  labs(x="Consonant Similarity", y="Vowel Similarity") +
  theme_light()

y_margin <- axis_canvas(p, axis='y') + geom_density(data=sim_data, aes(y=v_sim), fill='#969696') + geom_hline(yintercept=mean(sim_data$v_sim))
x_margin <- axis_canvas(p, axis='x') + geom_density(data=sim_data, aes(x=c_sim), fill='#969696') + geom_vline(xintercept=mean(sim_data$c_sim))

combined_plot <- insert_yaxis_grob(p, y_margin, position = "right")
fam_feat <- insert_xaxis_grob(combined_plot, x_margin, position = "top")

plot_grid(nc, feat, fam_nc, fam_feat, labels = "AUTO", label_size = 25, ncol=2)
ggsave('r/figures/similarity.pdf', width=8, height=8, units='in')


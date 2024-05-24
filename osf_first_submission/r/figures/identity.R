library(brms)
library(tidyverse)
library(tidybayes)
library(cowplot)

setwd('~/McGill/projects/co-ocurrence-harmony')


model <- readRDS('r/coling-jobs/5-3-non-adj-nc/model.rds')

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

ident_data <- draws %>% subset(term == 'ident_new')

p <- ggplot() +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.95, fill='#DDCC77', color='#DDCC77', geom='polygon') +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.75, fill='#CC6677', color='#CC6677', geom='polygon') +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.5, fill='#AA4499', color='#AA4499', geom='polygon') +
  geom_point(data=ident_intervals, aes(x=ident_coef_c, y=ident_coef_v)) +
  geom_smooth(data=ident_data %>% filter(.draw < 25), aes(x=c_ident, y=v_ident, group = .draw), method = "lm", se = F, size = 0.25, color='#3D3D3D') +
  geom_hline(aes(yintercept=0), lty=2, color='black') +
  geom_vline(aes(xintercept=0), lty=2, color='black') +
  labs(x="Consonant Identity", y="Vowel Identity") +
  theme_light()

y_margin <- axis_canvas(p, axis='y') + geom_density(data=ident_data, aes(y=v_ident), fill='#969696') + geom_hline(yintercept=mean(ident_data$v_ident))
x_margin <- axis_canvas(p, axis='x') + geom_density(data=ident_data, aes(x=c_ident), fill='#969696') + geom_vline(xintercept=mean(ident_data$c_ident))

combined_plot <- insert_yaxis_grob(p, y_margin, position = "right")
nc_ident <- insert_xaxis_grob(combined_plot, x_margin, position = "top")

##########################################

model <- readRDS('r/coling-jobs/5-3-non-adj-feat/model.rds')

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

ident_data <- draws %>% subset(term == 'ident_new')

p <- ggplot() +
  xlim(-3.1, 0.1) +
  ylim(-0.7, 1.3) +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.95, fill='#DDCC77', color='#DDCC77', geom='polygon') +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.75, fill='#CC6677', color='#CC6677', geom='polygon') +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.5, fill='#AA4499', color='#AA4499', geom='polygon') +
  geom_point(data=ident_intervals, aes(x=ident_coef_c, y=ident_coef_v)) +
  geom_smooth(data=ident_data %>% filter(.draw < 25), aes(x=c_ident, y=v_ident, group = .draw), method = "lm", se = F, size = 0.25, color='#3D3D3D') +
  geom_hline(aes(yintercept=0), lty=2, color='black') +
  geom_vline(aes(xintercept=0), lty=2, color='black') +
  labs(x="Consonant Identity", y="Vowel Identity") +
  theme_light()

y_margin <- axis_canvas(p, axis='y') + geom_density(data=ident_data, aes(y=v_ident), fill='#969696') + geom_hline(yintercept=mean(ident_data$v_ident))
x_margin <- axis_canvas(p, axis='x') + geom_density(data=ident_data, aes(x=c_ident), fill='#969696') + geom_vline(xintercept=mean(ident_data$c_ident))

combined_plot <- insert_yaxis_grob(p, y_margin, position = "right")
feat_ident <- insert_xaxis_grob(combined_plot, x_margin, position = "top")

########################

model <- readRDS('r/coling-jobs/5-4-non-adj-nc-family/model.rds')

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

ident_data <- draws %>% subset(term == 'ident_new')

p <- ggplot() +
  xlim(-2.7, .1) +
  ylim(-0.3, 1) +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.95, fill='#AA4499', color='#AA4499', geom='polygon') +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.75, fill='#CC6677', color='#CC6677', geom='polygon') +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.5, fill='#DDCC77', color='#DDCC77', geom='polygon') +
  geom_point(data=ident_intervals, aes(x=ident_coef_c, y=ident_coef_v)) +
  geom_smooth(data=ident_data %>% filter(.draw < 25), aes(x=c_ident, y=v_ident, group = .draw), method = "lm", se = F, size = 0.25, color='#3D3D3D') +
  geom_hline(aes(yintercept=0), lty=2, color='black') +
  geom_vline(aes(xintercept=0), lty=2, color='black') +
  labs(x="Consonant Identity", y="Vowel Identity") +
  theme_light()

y_margin <- axis_canvas(p, axis='y') + geom_density(data=ident_data, aes(y=v_ident), fill='#969696') + geom_hline(yintercept=mean(ident_data$v_ident))
x_margin <- axis_canvas(p, axis='x') + geom_density(data=ident_data, aes(x=c_ident), fill='#969696') + geom_vline(xintercept=mean(ident_data$c_ident))

combined_plot <- insert_yaxis_grob(p, y_margin, position = "right")
nc_fam_ident <- insert_xaxis_grob(combined_plot, x_margin, position = "top")


###########################

model <- readRDS('r/coling-jobs/5-4-non-adj-feat-family/model.rds')

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

ident_data <- draws %>% subset(term == 'ident_new')

p <- ggplot() +
  xlim(-2.7, .1) +
  ylim(-0.3, 1) +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.95, fill='#AA4499', color='#AA4499', geom='polygon') +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.75, fill='#CC6677', color='#CC6677', geom='polygon') +
  stat_ellipse(data=ident_data, aes(x = c_ident, y = v_ident), level=0.5, fill='#DDCC77', color='#DDCC77', geom='polygon') +
  geom_point(data=ident_intervals, aes(x=ident_coef_c, y=ident_coef_v)) +
  geom_smooth(data=ident_data %>% filter(.draw < 25), aes(x=c_ident, y=v_ident, group = .draw), method = "lm", se = F, size = 0.25, color='#3D3D3D') +
  geom_hline(aes(yintercept=0), lty=2, color='black') +
  geom_vline(aes(xintercept=0), lty=2, color='black') +
  labs(x="Consonant Identity", y="Vowel Identity") +
  theme_light()

y_margin <- axis_canvas(p, axis='y') + geom_density(data=ident_data, aes(y=v_ident), fill='#969696') + geom_hline(yintercept=mean(ident_data$v_ident))
x_margin <- axis_canvas(p, axis='x') + geom_density(data=ident_data, aes(x=c_ident), fill='#969696') + geom_vline(xintercept=mean(ident_data$c_ident))

combined_plot <- insert_yaxis_grob(p, y_margin, position = "right")
feat_fam_ident <- insert_xaxis_grob(combined_plot, x_margin, position = "top")

plot_grid(nc_ident, feat_ident, nc_fam_ident, feat_fam_ident, labels = "AUTO", label_size = 25, ncol=2)
ggsave('r/figures/identity.pdf', width=8, height=8, units='in')


library(brms)
library(tidyverse)
library(tidybayes)
library(cowplot)


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
ident_data <- draws %>% subset(term == 'ident_new')

data <- data.frame(
  language = sim_data$language,
  c_sim = sim_data$c_sim,
  v_sim = sim_data$v_sim,
  c_ident = ident_data$c_ident,
  v_ident = ident_data$v_ident,
  .draw = sim_data$.draw
)

lang_intervals <- data %>% group_by(language) %>% median_qi(sim_coef_c=c_sim, sim_coef_v=v_sim, ident_coef_c=c_ident, ident_coef_v=v_ident)

p <- ggplot() +
  stat_ellipse(data=data, aes(x = c_sim, y = c_ident), level=0.95, fill='#44AA99', color='#44AA99', geom='polygon') +
  stat_ellipse(data=data, aes(x = c_sim, y = c_ident), level=0.75, fill='#88CCEE', color='#88CCEE', geom='polygon') +
  stat_ellipse(data=data, aes(x = c_sim, y = c_ident), level=0.5, fill='#DDCC77', color='#DDCC77', geom='polygon') +
  geom_point(data=lang_intervals, aes(x=sim_coef_c, y=ident_coef_c)) +
  geom_smooth(data=data %>% filter(.draw < 25), aes(x=c_sim, y=c_ident, group = .draw), method = "lm", se = F, size = 0.25, color='#3D3D3D') +
  geom_hline(aes(yintercept=0), lty=2, color='black') +
  geom_vline(aes(xintercept=0), lty=2, color='black') +
  labs(x="Consonant Similarity", y="Consonant Identity") +
  theme_light()

y_margin <- axis_canvas(p, axis='y') + geom_density(data=data, aes(y=c_ident), fill='#969696') + geom_hline(yintercept=mean(data$c_ident))
x_margin <- axis_canvas(p, axis='x') + geom_density(data=data, aes(x=c_sim), fill='#969696') + geom_vline(xintercept=mean(data$c_sim))

combined_plot <- insert_yaxis_grob(p, y_margin, position = "right")
combined_plot <- insert_xaxis_grob(combined_plot, x_margin, position = "top")

ggdraw(combined_plot)

ggsave('r/figures/5_nc_cons.png', width=5, height=5, units='in')

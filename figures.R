library(brms)
library(bayestestR)
library(tidybayes)
library(latex2exp)
library(cowplot)
library(mgcv)
library(tidyverse)
library(ggridges)
library(cmdstanr)
library(showtext)

font_add("Fira Sans", "FiraSans-Regular.otf", bold = "FiraSans-Bold.otf")
showtext.auto()
showtext_opts(dpi = 600)

source("plot_funcs.R")

ndraws <- 10000

data <- load_data('sim', TRUE, TRUE)
c_data <- subset(data, isCons == TRUE)
v_data <- subset(data, isVow == TRUE)

theme_set(theme_clean(base_family = "Fira Sans", base_size = 11))

sim_data <- bind_rows(
  data %>% mutate(new_sim = nat_class_sim, type = paste0(isCons, "nc")),
  data %>% mutate(new_sim = sim, type = paste0(isCons, "feat"))
)

sim_data$type <- factor(sim_data$type, levels = c("1nc", "1feat", "0nc", "0feat"))

sim_plot <- sim_data %>% ggplot(aes(x = new_sim, fill = type, color = type, linetype = type)) +
  geom_density(
    adjust = 2,
    alpha = 0.7
  ) +
  ylim(0, 5) +
  xlab("Similarity") +
  ylab("Density") +
  labs(fill = "", color = "", linetype = "") +
  scale_linetype_manual(
    values=c(1,1,2,2),
    labels = c("C, Natural Class Similarity", "C, Feature Similarity", "V, Natural Class Similarity", "V, Feature Similarity")
  ) +
  scale_fill_manual(
    values=c("#397100", "#9FB783", "#732645", "#FE98BE"),
    labels = c("C, Natural Class Similarity", "C, Feature Similarity", "V, Natural Class Similarity", "V, Feature Similarity")
  ) +
  scale_color_manual(
    values=c("#397100", "#9FB783", "#732645", "#FE98BE"),
    labels = c("C, Natural Class Similarity", "C, Feature Similarity", "V, Natural Class Similarity", "V, Feature Similarity")
  ) +
  ggtitle("Similarity Metrics") +
  guides(
    fill=guide_legend(nrow=2,byrow=TRUE),
    color=guide_legend(nrow=2,byrow=TRUE),
    linetype=guide_legend(nrow=2,byrow=TRUE)
  ) +
  theme(
    plot.background = element_blank(),
    legend.position = 'bottom',
    legend.background = element_blank(),
    text = element_text(family = "Fira Sans"),
    legend.text = element_text(family = "Fira Sans", size = 9)
  )

ggsave('figures/sim_dist.png', sim_plot, width=15, height=8, units='cm', dpi=600)

model_feat <- readRDS('models/final_model/sim.rds')
model_nc <- readRDS('models/final_model/nat_class_sim.rds')

summary(model_nc)
summary(model_feat)

draws_nc <- get_draws(model_nc)
intervals_nc <- get_intervals(draws_nc)
draws_feat <- get_draws(model_feat)
intervals_feat <- get_intervals(draws_feat)

p <- plot_mod(draws_nc, intervals_nc, draws_feat, intervals_feat, 60000)
ggsave('figures/plots.png', p, width=15, height=15, units='cm', dpi=600)

pd(model_feat, effects='all')
pd(model_nc, effects='all')

###############################

languages <- data %>% group_by(language, isCons) %>%
  summarise(
    log_c_inv = mean(log_c_inv),
    log_v_inv = mean(log_v_inv),
    s1_freq_smooth = mean(data$s1_freq_smooth),
    s2_freq_smooth = mean(data$s2_freq_smooth),
    pairs_n = mean(pairs_n),
    family = first(family),
    subfamily = first(subfamily),
    isCons = first(isCons),
    isVow = first(isVow),
    min_sim = min(sim)
  )


# display_langs <- c('English', 'Basque', 'Mandarin Chinese', 'Polish', 'Turkish')
display_langs <- c('English', 'Turkish', 'Spanish', 'Standard Arabic', 'Basque')


plot_oe_cv(languages, model_nc, display_langs, FALSE, "Estimated O/E: Consonants, NC Model", "Estimated O/E: Vowels, NC Model")
ggsave('figures/oe_nc.pdf', width=15, height=8, units='cm', dpi=600)

plot_oe_cv(languages, model_feat, display_langs, TRUE,"Estimated O/E: Consonants, Feat Model", "Estimated O/E: Vowels, Feat Model")
ggsave('figures/oe_feat.pdf', width=15, height=8, units='cm', dpi=600)

bf1 <- bayesfactor_parameters(
  model_feat,
  direction = ">",
  effects = "random"
)

bf2 <- bayesfactor_parameters(
  model_nc,
  direction = ">",
  effects = "random"
)

hyp_sd <- c(
  "c_id_fam/c_id_lang" = "family__paircount_ident_new - family:language__paircount_ident_new > 0",
  "v_id_fam/v_id_lang" = "family__paircountv_ident_new - family:language__paircountv_ident_new > 0",
  "c_sim_fam/c_sim_lang" = "family__paircount_sim_new - family:language__paircount_sim_new > 0",
  "v_sim_fam/v_sim_lang" = "family__paircountv_sim_new - family:language__paircountv_sim_new > 0",
  "c_id_fam/c_sim_fam" = "family__paircount_ident_new - family__paircount_sim_new > 0",
  "v_id_fam/v_sim_fam" = "family__paircountv_ident_new - family__paircountv_sim_new > 0",
  "c_id_lang/c_sim_lang" = "family:language__paircount_ident_new - family:language__paircount_sim_new > 0",
  "v_id_lang/v_sim_lang" = "family:language__paircountv_ident_new - family:language__paircountv_sim_new > 0"
)

hypothesis(model_nc, hyp_sd, class="sd")
hypothesis(model_feat, hyp_sd, class="sd")

hyp_sd_cv <- c(
  "c_id_fam/v_id_fam" = "family__paircount_ident_new - family__paircountv_ident_new > 0",
  "c_sim_fam/v_sim_fam" = "family__paircount_sim_new - family__paircountv_sim_new > 0",
  "c_id_lang/v_id_lang" = "family:language__paircount_ident_new - family:language__paircountv_ident_new > 0",
  "c_sim_lang/v_sim_lang" = "family:language__paircount_sim_new - family:language__paircountv_sim_new > 0"
)

hypothesis(model_nc, hyp_sd_cv, class="sd")
hypothesis(model_feat, hyp_sd_cv, class="sd")

hyp_b = c(
  "v_id/v_sim" = "abs(paircountv_ident_new) - abs(paircountv_sim_new) > 0",
  "c_id/c_sim" = "abs(paircount_ident_new) - abs(paircount_sim_new) > 0",
  "c_sim/v_sim" = "abs(paircount_sim_new) - abs(paircountv_sim_new) > 0",
  "c_id/v_id" = "abs(paircount_ident_new) - abs(paircountv_ident_new) > 0",
  "c/v" = "(abs(paircount_sim_new) + abs(paircount_ident_new)) - (abs(paircountv_sim_new) + abs(paircountv_ident_new)) > 0"
)

hypothesis(model_nc, hyp_b, class="b")
hypothesis(model_feat, hyp_b, class="b")

samples <- get_samples(model_nc, model_feat)

b <- plot_posteriors_b(samples, "Main Effect Posteriors")
b
ggsave('figures/b_post.pdf', width=15, height=8, units='cm', dpi=600)

sd <- plot_posteriors_sd(samples, "Standard Deviation Posteriors")
sd
ggsave('figures/sd_post.pdf', width=15, height=8, units='cm', dpi=600)

b + sd + plot_layout(guides = 'collect')  &
  theme(
    plot.background = element_blank(),
    legend.position = 'bottom',
    legend.background = element_blank(),
    text = element_text(family = "Fira Sans"),
    legend.text = element_text(family = "Fira Sans", size = 9)
  )
ggsave('figures/b_sd_post.pdf', width=15, height=8, units='cm', dpi=600)

cor_fam <- plot_posteriors_cor(samples, "By Family Correlations", "family")  

cor_lang <- plot_posteriors_cor(samples, "By Language Correlations", "family:language")  

cor_fam + cor_lang + plot_layout(guides = 'collect') &
  theme(
    plot.background = element_blank(),
    legend.position = 'bottom',
    legend.background = element_blank(),
    text = element_text(family = "Fira Sans"),
    legend.text = element_text(family = "Fira Sans", size = 9)
  )
ggsave('figures/cor_post.pdf', width=15, height=8, units='cm', dpi=600)

pri <- plot_priors(samples, "Model Priors")  &
  theme(
    plot.background = element_blank(),
    legend.position = 'bottom',
    legend.background = element_blank(),
    text = element_text(family = "Fira Sans"),
    legend.text = element_text(family = "Fira Sans", size = 9)
  )
pri
ggsave('figures/prior.pdf', width=8, height=5, units='cm', dpi=600)


data_feat <- load_data('sim', TRUE, TRUE)
data_nc <- load_data('nat_class_sim', TRUE, TRUE)
data_nc$feat_sim <- data_feat$sim_new
data_nc$nc_sim <- data_nc$sim_new
data_nc <- data_nc %>% mutate(
  inv = ifelse(isVow == TRUE, mean(v_inv_size), mean(c_inv_size))
)

data_nc <- bind_rows(
  data_nc %>% mutate(new_sim = nc_sim, type = paste0(isCons, "nc")),
  data_nc %>% mutate(new_sim = feat_sim, type = paste0(isCons, "feat"))
)

inv_data <- data_nc %>% group_by(language, type) %>%
  reframe(
    v_inv = mean(v_inv_size),
    c_inv = mean(c_inv_size),
    inv = mean(inv),
    new_sim = mean(new_sim),
    isCons = first(isCons),
    isVow = first(isVow),
    type = first(type)
  )

inv_data %>% ggplot() +
  geom_point(aes(x = inv, y = new_sim, color = as.factor(type))) +
  geom_smooth(aes(x = inv, y = new_sim, color = as.factor(type)), method = "lm") +
  scale_color_manual(
    values=c("#397100", "#9FB783", "#732645", "#FE98BE"),
    labels = c("C, Natural Class Similarity", "C, Feature Similarity", "V, Natural Class Similarity", "V, Feature Similarity")
  ) +
  ggtitle("Inventory Size v. Similarity") +
  xlab("Inventory Size") +
  ylab("Mean Similarity") +
  labs(fill = "", color = "", linetype = "") +
  theme(
    plot.background = element_blank(),
    legend.position = 'bottom',
    legend.background = element_blank(),
    text = element_text(family = "Fira Sans"),
    legend.text = element_text(family = "Fira Sans", size = 9)
  ) +
  guides(
    fill=guide_legend(nrow=2,byrow=TRUE),
    color=guide_legend(nrow=2,byrow=TRUE),
    linetype=guide_legend(nrow=2,byrow=TRUE)
  )


ggsave('figures/inv_size.png', width=12, height=10, units='cm', dpi=600)


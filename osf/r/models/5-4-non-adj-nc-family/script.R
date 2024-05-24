library(brms)
library(bayestestR)

data <- read.csv('data/r_data/northeuralex_non_adj.csv')
data$type <- as.factor(data$type)
data$language <- as.factor(data$language)
data$family <- as.factor(data$family)
data$s1 <- as.factor(data$s1)
data$s2 <- as.factor(data$s2)


data$pair_count_v = data$pair_count
data$isCons <- ifelse(data$type=='cons', 1, 0)
data$isVow <- ifelse(data$type=='vowels', 1, 0)
data$log_v_inv <- log(data$v_inv_size)
data$log_c_inv <- log(data$c_inv_size)
data$ident_new <- ifelse(data$s1 == data$s2, 1, 0)
data$sim_new <- ifelse(data$s1 == data$s2, 0, data$nat_class_sim)

summary(data)

c_model_rand = bf(pair_count | subset(isCons) ~ offset(s1_freq + s2_freq) + log_c_inv + log_v_inv + sim_new + ident_new + (ident_new + sim_new | q | family) + (ident_new + sim_new | p | family:language), family=negbinomial)
v_model_rand = bf(pair_count_v | subset(isVow) ~ offset(s1_freq + s2_freq) + log_c_inv + log_v_inv + sim_new + ident_new + (ident_new + sim_new | q | family) + (ident_new + sim_new | p | family:language), family=negbinomial)

sample_rand_langs_mod <- brm(
  c_model_rand + v_model_rand,
  data=data,
  prior = c(set_prior('normal(0, 4)', class='Intercept', resp=c('paircount', 'paircountv')),
            set_prior('normal(0, 4)', class='b', resp=c('paircount', 'paircountv')),
            set_prior('lkj_corr(1.5)', class='L')
  ),
  control = list(adapt_delta = 0.95),
  iter = 8000,
  warmup = 2000,
  chains = 4,
  cores = 4,
  save_pars = save_pars(all = TRUE),
  file='r/models/5-4-non-adj-nc-family/model'
)

bf_pointnull(sample_rand_langs_mod)

summary(sample_rand_langs_mod)
plot(sample_rand_langs_mod)

library(brms)
library(bayestestR)

data <- read.csv('data/r_data/SalamaArb_non_adj.csv')
data$type <- as.factor(data$type)
data$language <- as.factor(data$language)
data$s1 <- as.factor(data$s1)
data$s2 <- as.factor(data$s2)


data$pair_count_v = data$pair_count
data$isCons <- ifelse(data$type=='cons', 1, 0)
data$isVow <- ifelse(data$type=='vowels', 1, 0)
data$log_v_inv <- log(data$v_inv_size)
data$log_c_inv <- log(data$c_inv_size)
data$ident_new <- ifelse(data$s1 == data$s2, 1, 0)
data$sim_new <- ifelse(data$s1 == data$s2, 0, data$sim)

summary(data)

# c_model_rand = bf(pair_count | subset(isCons) ~ offset(s1_freq + s2_freq) + log_c_inv + log_v_inv + sim_new + ident_new + (ident_new + sim_new | q | language), family=negbinomial)
v_model_rand = bf(pair_count_v ~ offset(s1_freq + s2_freq) + sim_new + ident_new, family=negbinomial)

sample_rand_langs_mod <- brm(
  v_model_rand,
  data=data,
  prior = c(set_prior('normal(0, 4)', class='Intercept'),
            set_prior('normal(0, 4)', class='b')
  ),
  control = list(adapt_delta = 0.95),
  iter = 30000,
  warmup = 5000,
  chains = 4,
  cores = 4,
  save_pars = save_pars(all = TRUE),
  file='r/models/arabic/model'
)

bf_pointnull(sample_rand_langs_mod)

summary(sample_rand_langs_mod)
plot(sample_rand_langs_mod)

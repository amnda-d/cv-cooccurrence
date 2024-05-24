library(brms)
library(bayestestR)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

sim_type <- args[1]
model <- args[2]

data <- read.csv('data/r_data/northeuralex_freq.csv')

data <- data %>%
    mutate(
        family = replace(
            family,
            family == "indo-european",
            subfamily[family == "indo-european"]
        )
    )
data <- data %>%
    mutate(
        family = replace(
            family,
            family == "uralic",
            subfamily[family == "uralic"]
        )
    )

data$type <- as.factor(data$type)
data$language <- as.factor(data$language)
data$family <- as.factor(data$family)
data$s1 <- as.factor(data$s1)
data$s2 <- as.factor(data$s2)


data$pair_count_v <- data$pair_count
data$isCons <- ifelse(data$type == "cons", 1, 0)
data$isVow <- ifelse(data$type == "vowels", 1, 0)
data$log_v_inv <- log(data$v_inv_size)
data$log_c_inv <- log(data$c_inv_size)
data$ident_new <- ifelse(data$s1 == data$s2, 1, 0)
data$sim_new <- data[[sim_type]]
data$sim_new <- ifelse(data$s1 == data$s2, 0, data$sim_new)
data$s1_count_smooth <- data$s1_count + 1
data$s2_count_smooth <- data$s2_count + 1
data <- data %>%
  group_by(language, isCons) %>%
  mutate(
    pairs_n = sum(pair_count)
  )
data <- data %>%
  group_by(language, isCons) %>%
  mutate(
    s1_freq_smooth = log(s1_count_smooth / pairs_n),
    s2_freq_smooth = log(s2_count_smooth / pairs_n)
  )

summary(data)

c_model_rand <- bf(
    pair_count | subset(isCons) ~
        offset(s1_freq_smooth + s2_freq_smooth) +
        log_c_inv + log_v_inv + sim_new + ident_new +
        (ident_new + sim_new | p | family) +
        (ident_new + sim_new | q | family:language),
    shape ~ 0 + (1 | family) + (1 | family:language),
    cmc = FALSE,
    family = negbinomial
    )
v_model_rand <- bf(
    pair_count_v | subset(isVow) ~
        offset(s1_freq_smooth + s2_freq_smooth) +
        log_c_inv + log_v_inv + sim_new + ident_new +
        (ident_new + sim_new | p | family) +
        (ident_new + sim_new | q | family:language),
    shape ~ 0 + (1 | family) + (1 | family:language),
    cmc = FALSE,
    family = negbinomial
    )

mod <- brm(
  c_model_rand + v_model_rand,
  data = data,
  prior = c(
    set_prior('normal(0, 4)', class='Intercept', resp=c('paircount', 'paircountv')),
    set_prior('normal(0, 4)', class='b', resp=c('paircount', 'paircountv')),
    set_prior('lkj_corr(1.5)', class='L'
    )
  ),
  control = list(adapt_delta = 0.95),
  iter = 20000,
  warmup = 5000,
  chains = 4,
  cores = 4,
  backend = "cmdstanr",
  threads = threading(4),
  save_pars = save_pars(all = TRUE),
  sample_prior = "yes",
  file = paste('models/', model, '/', sim_type, sep = ''),
  silent = 0
)

bf_pointnull(mod, effects = "random")
bf_pointnull(mod)
pd(mod, effects = "all")

summary(mod)
plot(mod)

library(brms)
library(bayestestR)
library(tidybayes)
library(dplyr)
library(tidyr)
library(ggplot2)
library(latex2exp)
# library(cowplot)
library(hrbrthemes)
library(ggthemes)
library(ggridges)
library(stringr)
library(MASS)
library(terra)
library(patchwork)

load_data <- function(sim_type, indo, uralic) {
  data <- read.csv('data/r_data/northeuralex_freq.csv')
  
  if(indo) {
    data <- data %>%
      mutate(
        family = replace(
          family,
          family == "indo-european",
          subfamily[family == "indo-european"]
        )
      )
  }
  
  if(uralic) {
    data <- data %>%
      mutate(
        family = replace(
          family,
          family == "uralic",
          subfamily[family == "uralic"]
        )
      )
  }
  
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
  return(data)
}

get_draws <- function(model) {
  lang <- model %>% spread_draws(
    `r_family:language__paircount`[language, term],
    `r_family:language__paircountv`[language, term]
  ) %>% mutate(
    family = str_extract(language, "(^[^_]+)_", group = TRUE)
  )
  
  fam <- model %>% spread_draws(
    `r_family__paircount`[family, term],
    `r_family__paircountv`[family, term]
  )
  
  b <- model %>% spread_draws(
    b_paircount_sim_new,
    b_paircountv_sim_new,
    b_paircount_ident_new,
    b_paircountv_ident_new
  )
  
  draws <- left_join(fam, lang, by=c('family', 'term', '.draw', '.iteration', '.chain')) %>% pivot_wider(
    names_from='term', values_from=c(
      "r_family__paircount",
      "r_family:language__paircount",
      "r_family__paircountv",
      "r_family:language__paircountv"
    )
  )
  
  draws <- left_join(draws, b, by=c('.draw', '.iteration', '.chain'))
  
  draws$c_sim <- draws$`r_family:language__paircount_sim_new` +
    draws$`r_family__paircount_sim_new` +
    draws$b_paircount_sim_new
  draws$v_sim <- draws$`r_family:language__paircountv_sim_new` +
    draws$`r_family__paircountv_sim_new` +
    draws$b_paircountv_sim_new
  draws$c_ident <- draws$`r_family:language__paircount_ident_new` +
    draws$`r_family__paircount_ident_new` +
    draws$b_paircount_ident_new
  draws$v_ident <- draws$`r_family:language__paircountv_ident_new` +
    draws$`r_family__paircountv_ident_new` +
    draws$b_paircountv_ident_new
  draws$c_coef <- draws$c_sim + draws$c_ident
  draws$v_coef <- draws$v_sim + draws$v_ident
  
  return(draws)
}

get_intervals <- function(draws) {
  sim_intervals <- draws %>% group_by(language) %>%
    median_qi(c_sim = c_sim, v_sim = v_sim)
  ident_intervals <- draws %>% group_by(language) %>%
    median_qi(c_ident = c_ident, v_ident = v_ident)
  combined_intervals <- draws %>% group_by(language) %>%
    median_qi(c_coef = c_coef, v_coef = v_coef)
  
  intervals <- left_join(sim_intervals, ident_intervals, by="language")
  intervals <- left_join(intervals, combined_intervals, by="language")
  
  return(intervals)
}

density_quantiles <- function(x, y, quantiles) {
  # https://stackoverflow.com/a/75629415
  dens <- MASS::kde2d(x, y, n = 50)
  df   <- cbind(expand.grid(x = dens$x, y = dens$y), z = c(dens$z))
  r    <- terra::rast(df)
  ind  <- sapply(seq_along(x), function(i) cellFromXY(r, cbind(x[i], y[i])))
  ind  <- ind[order(-r[ind][[1]])]
  vals <- r[ind][[1]]
  ret  <- approx(seq_along(ind)/length(ind), vals, xout = quantiles)$y
  replace(ret, is.na(ret), max(r[]))
}

plot_x_y <- function(draws, intervals, x_axis, y_axis, n_samples, xlim1, xlim2, ylim1, ylim2, ytext = TRUE, xlab = "", ylab = "", title = "") {
  d <- draws %>% group_by(language) %>% slice_sample(n=n_samples)
  quantiles <- c(0, 0.5, 0.75, 0.95)
  
  quant <- density_quantiles(d[[x_axis]], d[[y_axis]], quantiles)

  p <- d %>% ggplot(aes(x = .data[[x_axis]], y = .data[[y_axis]])) +
    geom_density2d_filled(
      aes(fill = after_stat(level)),
      contour_var = "density",
      breaks = quant
    ) +
    coord_equal() +
    scale_fill_manual(values=c("#CC4C02", "#FB9A29", "#FEE391", "#969696")) +
    geom_hline(aes(yintercept=0), lty=2, color='black') +
    geom_vline(aes(xintercept=0), lty=2, color='black') +
    geom_point(data=intervals, aes(x = .data[[x_axis]], y =.data[[y_axis]]), size = 0.8) +
    xlim(xlim1, xlim2) +
    ylim(ylim1, ylim2) +
    labs(x=xlab, y=ylab) +
    ggtitle(title) +
    theme(
      aspect.ratio = 1,
      axis.title.y = element_text(),
      axis.title.x = element_text(),
      legend.position="none",
      # panel.background = element_blank(),
      plot.background = element_rect(fill = "white"),
      axis.text.y = ifelse(ytext, element_text, element_blank)(),
      plot.title = element_text(margin=margin(b = 35)),
      plot.margin = margin(r=30, t = 10),
      panel.background = element_rect(color = "black"),
      text = element_text(family = "Fira Sans"),
      legend.text = element_text(family = "Fira Sans", size = 9)
    )

  y_med <- median(d[[y_axis]])
  y_max <- filter(as.data.frame(density(d[[y_axis]], n=512)[1:2]), abs(x - y_med) == min(abs(x - y_med)))$y
  
  y_margin <- d %>% ggplot(aes(y = .data[[y_axis]])) +
    ylim(ylim1, ylim2) +
    geom_density(orientation = "y", fill='#969696', color = 'NA') +
    # geom_vline(xintercept = 0) +
    geom_segment(x = 0, xend = y_max, y = y_med, yend = y_med) +
    theme_solid()
  
  x_med <- median(d[[x_axis]])
  x_max <- filter(as.data.frame(density(d[[x_axis]], n=512)[1:2]), abs(x - x_med) == min(abs(x - x_med)))$y
  
  x_margin <- d %>% ggplot(aes(x = .data[[x_axis]])) +
    xlim(xlim1, xlim2) +
    geom_density(orientation = "x", fill='#969696', color = 'NA') +
    # geom_hline(yintercept = 0) +
    geom_segment(x = x_med, xend = x_med, y = 0, yend = x_max) +
    theme_solid()
  
  p <- p +
    inset_element(x_margin, left = 0, bottom = 0.945, right = 1, top = 1.2) +
    inset_element(y_margin, left = 0.945, bottom = 0, right = 1.2, top = 1)
  
  p
}

# a <- plot_x_y(
#   draws_nc,
#   intervals_nc,
#   'c_sim', 'v_sim',
#   50,
#   -1.6, 0.4, -0.6, 0.8,
#   TRUE,
#   TeX(r"(C Similarity ($\beta_{sim|C} + \gamma_{sim|C} + \alpha_{sim|C}$))"),
#   TeX(r"(V Similarity ($\beta_{sim|V} + \gamma_{sim|V} + \alpha_{sim|V}$))"),
#   "titlea"
# )
# 
# b <- plot_x_y(
#   draws_nc,
#   intervals_nc,
#   'c_sim', 'v_sim',
#   50,
#   -1.6, 0.4, -0.6, 0.8,
#   TRUE,
#   TeX(r"(C Similarity ($\beta_{sim|C} + \gamma_{sim|C} + \alpha_{sim|C}$))"),
#   TeX(r"(V Similarity ($\beta_{sim|V} + \gamma_{sim|V} + \alpha_{sim|V}$))"),
#   "titleb"
# )
# wrap_plots(wrap_elements(a), b, a, b)
# ggsave('test.pdf', width=8, height=8, units='in')

plot_mod <- function(draws_nc, intervals_nc, draws_feat, intervals_feat, n_samples) {
  # p1 <- plot_x_y(draws_nc, intervals_nc, 'c_coef', 'v_coef', -3.3, 0.1, -0.7, 1.5, '#DDAA33', '#BB5566', '#6699CC', TeX("$sim_C + ident_C$"),  TeX("$sim_V + ident_V$"))
  p2 <- plot_x_y(
    draws_nc,
    intervals_nc,
    'c_sim', 'v_sim',
    n_samples,
    # -1.6, 0.4, -0.6, 0.8,
    -2.3, 0.4, -0.8, 1.5,
    TRUE,
    TeX(r"(C Similarity ($\beta_{sim|C} + \gamma_{sim|C} + \alpha_{sim|C}$))"),
    TeX(r"(V Similarity ($\beta_{sim|V} + \gamma_{sim|V} + \alpha_{sim|V}$))"),
    "Similarity, NC Model"
  )
  # p3 <- plot_x_y(draws, intervals, 'c_sim', 'v_ident', 'C sim', 'V ident')
  # p4 <- plot_x_y(draws, intervals, 'c_sim', 'c_ident', 'C sim', 'C ident')
  p5 <- plot_x_y(
    draws_nc,
    intervals_nc,
    'c_ident', 'v_ident',
    n_samples,
    -2.3, 0.4, -0.8, 1.5,
    TRUE,
    TeX(r"(C Identity ($\beta_{ident|C} + \gamma_{ident|C} + \alpha_{ident|C}$))"),
    TeX(r"(V Identity ($\beta_{ident|V} + \gamma_{ident|V} + \alpha_{ident|V}$))"),
    "Identity, NC Model"
  )
  # p6 <- plot_x_y(draws, intervals, 'c_ident', 'v_sim', 'C ident', 'V sim')
  # p7 <- plot_x_y(draws, intervals, 'v_sim', 'v_ident', 'V sim', 'V ident')
  
  # p12 <- plot_x_y(draws_feat, intervals_feat, 'c_coef', 'v_coef', -3.3, 0.1, -0.7, 1.5, '#DDAA33', '#BB5566', '#6699CC', TeX("$sim_C + ident_C$"),  TeX("$sim_V + ident_V$"))
  p22 <- plot_x_y(
    draws_feat,
    intervals_feat,
    'c_sim', 'v_sim',
    n_samples,
    # -1.6, 0.4, -0.6, 0.8,
    -2.3, 0.4, -0.8, 1.5,
    FALSE,
    TeX(r"(C Similarity ($\beta_{sim|C} + \gamma_{sim|C} + \alpha_{sim|C}$))"),
    # TeX(r"(V Similarity ($\beta_{sim|V} + \gamma_{sim|V} + \alpha_{sim|V}$))"),
    "",
    "Similarity, Feat Model"
  )
  p52 <- plot_x_y(
    draws_feat,
    intervals_feat,
    'c_ident', 'v_ident',
    n_samples,
    -2.3, 0.4, -0.8, 1.5,
    FALSE,
    TeX(r"(C Identity ($\beta_{ident|C} + \gamma_{ident|C} + \alpha_{ident|C}$))"),
    # TeX(r"(V Identity ($\beta_{ident|V} + \gamma_{ident|V} + \alpha_,{ident|V}$))"),
    "",
    "Identity, Feat Model"
  )
  # plot_grid(p2, p22, p5, p52, labels = "AUTO", label_size = 25, ncol=2)
  # p2 + p22 + p5 + p52 + plot_layout(heights = 1, widths = 1)
  p <- wrap_plots(p2, p22, p5, p52) &
    theme(
      plot.background = element_blank()
    )
  return(p)
}

plot_oe <- function(languages, model, resp, display_langs, lab, laby, feat=FALSE, title="") {
  sim_vals <- data.frame(sim_new = seq(from = 0.0, to = 1.0, by = 0.005))
  
  newdata <- cross_join(languages, sim_vals) %>% mutate(
    ident_new = ifelse(sim_new == 1.0, 1, 0),
    sim_new = ifelse(sim_new == 1.0, 0.0, sim_new)
  )
  
  if (feat) {
    newdata <- newdata %>% filter(sim_new >= min_sim)
    
    id <- languages %>%
      mutate(ident_new = 1) %>%
      mutate(sim_new = 0.0)
    
    newdata <- bind_rows(newdata, id)
  }
  
  x <- fitted(
    model,
    newdata = newdata,
    resp = resp,
    ndraws = 1000,
    offset = FALSE
  )
  
  x <- data.frame(x)
  
  if (resp == 'paircountv') {
    newdata <- filter(newdata, isVow == 1)
  } else {
    newdata <- filter(newdata, isCons == 1)
  }
  
  newdata$med <- x$Estimate / newdata$pairs_n
  newdata$upper <- x$Q2.5 / newdata$pairs_n
  newdata$lower <- x$Q97.5 / newdata$pairs_n
  
  newdata <- newdata %>% mutate(
    sim_new = ifelse(ident_new == 1, 1.15, sim_new)
  )
  
  x <- newdata %>% filter(ident_new != 1) %>%
    ggplot(aes(x=sim_new, y = med, color = language, group = language)) +
    geom_smooth(se=FALSE)
  
  langs <- (newdata %>% filter(sim_new == 1.15))$language
  
  start <- (layer_data(x, 1) %>% filter(x == 0.995))$y
  end <- (newdata %>% filter(sim_new == 1.15))$med
  interpolate <- data.frame(
    language = c(langs, langs),
    med = c(start, end),
    sim_new = c(
      (newdata %>% filter(sim_new == 0.995))$sim_new,
      (newdata %>% filter(sim_new == 1.15))$sim_new
    )
  )
  
  interpolate$language <- str_to_title(interpolate$language)
  newdata$language <- str_to_title(newdata$language)
  
  p <- newdata %>% filter(ident_new != 1) %>%
    ggplot(aes(x=sim_new, y = med, group = language)) +
    geom_smooth(
      se=FALSE,
      color = '#BBBBBB',
      linewidth = 0.2
    ) +
    geom_line(
      data = interpolate,
      lty = 2,
      color = '#BBBBBB',
      linewidth = 0.2
    ) +
    geom_point(
      data = newdata %>% filter(ident_new == 1),
      color = '#BBBBBB',
      size = 0.3
    ) +
    geom_ribbon(
      aes(fill = language, ymin = lower, ymax = upper),
      data = newdata %>% filter(ident_new != 1) %>% filter(language %in% display_langs),
      alpha=0.2
    ) +
    geom_smooth(
      aes(color = language),
      data = newdata %>% filter(ident_new != 1) %>% filter(language %in% display_langs),
      se=FALSE,
      linewidth = 0.8
    ) +
    geom_line(
      aes(color = language),
      data = interpolate %>% filter(language %in% display_langs),
    ) +
    geom_point(
      aes(color = language),
      data = newdata %>% filter(ident_new == 1) %>% filter(language %in% display_langs),
      size = 1.3
    ) +
    geom_hline(aes(yintercept=1), lty=3, color='black') +
    # theme(legend.position="none") +
    scale_y_log10(limits = c(0.3, 2.8)) +
    annotation_logticks(sides="l") +
    scale_x_continuous(breaks=c(0.0, 0.25, 0.5, 0.75, 0.995, 1.15), labels=c("0.00", "0.25", "0.5", "0.75", "0.995", "Identity")) +
    xlab(lab) +
    ylab(laby) +
    ggtitle(title) +
    scale_color_manual(values=c("#0077BB", "#33BBEE", "#009988", "#EE7733", "#CC3311", "#EE3377")) +
    scale_fill_manual(values=c("#0077BB", "#33BBEE", "#009988", "#EE7733", "#CC3311", "#EE3377")) +
    theme(
      axis.title.y = element_text(),
      axis.title.x = element_text(),
      plot.background = element_blank(),
      text = element_text(family = "Fira Sans"),
      legend.text = element_text(family = "Fira Sans", size = 9)
    )
  return(p)
  # if(legend) {
  #   return(p)
  # } else {
  #   return(p + theme(legend.position="none"))
  # }
}
  
  
plot_oe_cv <- function(languages, model, display_langs, feat=FALSE, ctitle, vtitle) {
  c <- plot_oe(languages, model, 'paircount', display_langs, 'Consonant Similarity', 'Estimated O/E Ratio', feat, ctitle)
  v <- plot_oe(languages, model, 'paircountv', display_langs, 'Vowel Similarity', '', feat, vtitle)
  
  # legend <- get_legend(
  #   c + guides(color = guide_legend(nrow = 1)) +
  #     theme(legend.position = "bottom") +
  #     theme(legend.title=element_blank())
  # )
  
  # pgrid <- plot_grid(c + theme(legend.position="none"), v + theme(legend.position="none") + ylab(""))
  
  # plot_grid(
  #   pgrid,
  #   legend,
  #   ncol = 1,
  #   rel_heights = c(1, .1)
  # )
  return(
    c + v +
      plot_layout(guides = 'collect') &
      theme(
        plot.background = element_blank(),
        legend.position = 'bottom',
        legend.background = element_blank(),
        axis.line.y = element_line(),
        legend.title=element_blank(),
        text = element_text(family = "Fira Sans"),
        legend.text = element_text(family = "Fira Sans", size = 9)
      )
  )
  # plot_grid(c, v, labels = NULL, label_size = 25, ncol=2, rel_widths = c(1, 1.4))
}


get_samples <- function(nc, feat) {
  draws <- nc %>% gather_draws(
    `(b|(sd)|(cor))_[^I]*`,
    regex=TRUE
  ) %>% mutate(
    type = "posterior",
    var_cat = str_extract(.variable, "^[^_]+"),
    cv = str_extract(.variable, "paircount[^_]?"),
    var_name = str_extract(.variable, "(?<=paircount)v?_(.*)", group=TRUE),
    ranef = str_replace_na(str_extract(.variable, "^[^_]+_([^_]+)__", group=TRUE), "")
  ) %>% mutate(
    type = paste0(type, "_", ifelse(var_cat == "cor", "", cv), "_nc"),
    var_name = ifelse(var_cat == "cor", paste0(str_extract(.variable, "(?<=__)(.*)", group=TRUE), ranef), paste0(var_name, ranef))
  )
  
  prior <- prior_draws(
    nc, c(
      "b_paircount_log_c_inv",                                         
      "b_paircount_log_v_inv",                                         
      "b_paircount_sim_new",                                           
      "b_paircount_ident_new",                                         
      "b_paircountv_log_c_inv",                                        
      "b_paircountv_log_v_inv",                                        
      "b_paircountv_sim_new",                                          
      "b_paircountv_ident_new",                                        
      "sd_family__paircount_ident_new",                                
      "sd_family__paircount_sim_new",                                  
      "sd_family__paircountv_ident_new",                               
      "sd_family__paircountv_sim_new",                                 
      "sd_family:language__paircount_ident_new",                       
      "sd_family:language__paircount_sim_new",                         
      "sd_family:language__paircountv_ident_new",                      
      "sd_family:language__paircountv_sim_new",
      "cor_family__paircount_ident_new__paircount_sim_new",            
      "cor_family__paircount_ident_new__paircountv_ident_new",         
      "cor_family__paircount_sim_new__paircountv_ident_new",           
      "cor_family__paircount_ident_new__paircountv_sim_new",           
      "cor_family__paircount_sim_new__paircountv_sim_new",             
      "cor_family__paircountv_ident_new__paircountv_sim_new",          
      "cor_family:language__paircount_ident_new__paircount_sim_new",   
      "cor_family:language__paircount_ident_new__paircountv_ident_new",
      "cor_family:language__paircount_sim_new__paircountv_ident_new",  
      "cor_family:language__paircount_ident_new__paircountv_sim_new",  
      "cor_family:language__paircount_sim_new__paircountv_sim_new",    
      "cor_family:language__paircountv_ident_new__paircountv_sim_new" 
    )
  ) %>% pivot_longer(
    everything(),
    names_to = ".variable",
    values_to = ".value"
  ) %>% mutate(
    type = "prior",
    var_cat = str_extract(.variable, "^[^_]+"),
    cv = str_extract(.variable, "paircount[^_]?"),
    var_name = str_extract(.variable, "(?<=paircount)v?_(.*)", group=TRUE),
    ranef = str_replace_na(str_extract(.variable, "^[^_]+_([^_]+)__", group=TRUE), "")
  ) %>% mutate(
    var_name = ifelse(var_cat == "cor", paste0(str_extract(.variable, "(?<=__)(.*)", group=TRUE), ranef), paste0(var_name, ranef))
  )
  
  draws2 <- feat %>% gather_draws(
    `(b|(sd)|(cor))_[^I]*`,
    regex=TRUE
  ) %>% mutate(
    type = "posterior",
    var_cat = str_extract(.variable, "^[^_]+"),
    cv = str_extract(.variable, "paircount[^_]?"),
    var_name = str_extract(.variable, "(?<=paircount)v?_(.*)", group=TRUE),
    ranef = str_replace_na(str_extract(.variable, "^[^_]+_([^_]+)__", group=TRUE), "")
  ) %>% mutate(
    type = paste0(type, "_", ifelse(var_cat == "cor", "", cv), "_feat"),
    var_name = ifelse(var_cat == "cor", paste0(str_extract(.variable, "(?<=__)(.*)", group=TRUE), ranef), paste0(var_name, ranef))
  )
  
  data <- bind_rows(draws, draws2, prior) %>% mutate(
    type = case_match(
      type,
      "prior" ~ "Prior",
      "posterior__feat" ~ "Feat Model",
      "posterior__nc" ~ "NC Model",
      "posterior_paircount_feat" ~ "C, Feat Model",
      "posterior_paircount_nc" ~ "C, NC Model",
      "posterior_paircountv_feat" ~ "V, Feat Model",
      "posterior_paircountv_nc" ~ "V, NC Model"
    )
  )
  
  data$type <- factor(
    data$type,
    levels = c(
      "Prior",
      "C, NC Model",
      "C, Feat Model",
      "V, NC Model",
      "V, Feat Model",
      "NC Model",
      "Feat Model"
    ),
    ordered = TRUE
  )
  
  data
}

colorscale <- c(
  "#6699CC",
  "#004488",
  "#EE99AA",
  "#994455",
  "#EECC66",
  "#997700"
)

colorscale1 <- c(
  "#639EFE",
  "#397100",
  "#9FB783",
  "#732645",
  "#FE98BE"
)


plot_posteriors_b <- function(data, title) {
  data <- data %>% filter(
    str_detect(.variable, "b")
  )
  
  tex_labels = c(
    "log_c_inv" = TeX(r"($\beta_{C.inv}$)"),                
    "sim_new" = TeX(r"($\beta_{sim}$)"),
    "ident_new" = TeX(r"($\beta_{ident}$)"),
    "log_v_inv" = TeX(r"($\beta_{V.inv}$)")
  )
  
  # colorscale <- c(
  #   "#6699CC",
  #   "#EE99AA",
  #   "#004488",
  #   "#994455",
  #   "#997700"
  # )
  
  p <- data %>% ggplot() +
    geom_density_ridges(
      aes(x = .value, y = var_name, color = type, fill = type, linetype = type, height = after_stat(density)),
      alpha = 0.7,
      stat = "density",
      trim = TRUE,
      scale = 1.25
    ) +
    xlim(-1.5, 1) +
    ggtitle(title) +
    coord_cartesian(clip = "off") +
    scale_y_discrete(labels = tex_labels) +
    theme(legend.title=element_blank()) +
    scale_color_manual(values=colorscale1) +
    scale_fill_manual(values=colorscale1) +
    scale_linetype_manual(values = c(4, 1, 1, 2, 2)) +
    xlab(TeX(r"($\beta$ Value)")) +
    ylab("") +
    geom_vline(xintercept=0) +
    theme(
      legend.position = 'bottom',
      legend.background = element_blank(),
      legend.box="vertical",
      text = element_text(family = "Fira Sans"),
      legend.text = element_text(family = "Fira Sans", size = 9)
    )
  
}

plot_posteriors_sd <- function(data, title) {
  data <- data %>% filter(
    str_detect(.variable, "sd")
  )
  
  tex_labels = c(
    "ident_newfamily" = TeX(r"($\sigma(\gamma_{ident})$)"),
    "sim_newfamily" = TeX(r"($\sigma(\gamma_{sim})$)"),
    "ident_newfamily:language" = TeX(r"($\sigma(\alpha_{ident})$)"),
    "sim_newfamily:language" = TeX(r"($\sigma(\alpha_{sim})$)")
  )
  
  # colorscale <- c(
  #   "#6699CC",
  #   "#EE99AA",
  #   "#004488",
  #   "#994455",
  #   "#997700"
  # )
  
  p <- data %>% ggplot() +
    geom_density_ridges(
      aes(x = .value, y = var_name, color = type, fill = type, linetype = type, height = after_stat(density)),
      alpha = 0.7,
      stat = "density",
      trim = TRUE,
      scale = 1.25
    ) +
    xlim(0, 1) +
    ggtitle(title) +
    coord_cartesian(clip = "off") +
    scale_y_discrete(labels = tex_labels) +
    theme(legend.title=element_blank()) +
    scale_color_manual(values=colorscale1) +
    scale_fill_manual(values=colorscale1) +
    scale_linetype_manual(values = c(4, 1, 1, 2, 2)) +
    xlab(TeX(r"($\sigma$ Value)")) +
    ylab("") +
    theme(
      legend.position = 'bottom',
      legend.background = element_blank(),
      legend.box="vertical",
      text = element_text(family = "Fira Sans"),
      legend.text = element_text(family = "Fira Sans", size = 9)
    )
}

plot_posteriors_cor <- function(data, title, rand_eff) {
  data <- data %>% filter(
    var_cat == "cor",
    ranef == rand_eff
  )
  
  tex_labels = c(
    "paircount_ident_new__paircount_sim_newfamily" = TeX(r"($\rho(\gamma_{ident|C}, \gamma_{sim|C})$)"),
    "paircount_ident_new__paircountv_ident_newfamily" = TeX(r"($\rho(\gamma_{ident|C}, \gamma_{ident|V})$)"),
    "paircount_sim_new__paircountv_ident_newfamily" = TeX(r"($\rho(\gamma_{sim|C}, \gamma_{ident|V})$)"),
    "paircount_ident_new__paircountv_sim_newfamily" = TeX(r"($\rho(\gamma_{ident|C}, \gamma_{sim|V})$)"),
    "paircount_sim_new__paircountv_sim_newfamily" = TeX(r"($\rho(\gamma_{sim|C}, \gamma_{sim|V})$)"),
    "paircountv_ident_new__paircountv_sim_newfamily" = TeX(r"($\rho(\gamma_{ident|V}, \gamma_{sim|V})$)"),
    "paircount_ident_new__paircount_sim_newfamily:language" = TeX(r"($\rho(\alpha_{ident|C}, alpha_{sim|C})$)"),
    "paircount_ident_new__paircountv_ident_newfamily:language" = TeX(r"($\rho(\alpha_{ident|C}, \alpha_{ident|V})$)"),
    "paircount_sim_new__paircountv_ident_newfamily:language" = TeX(r"($\rho(alpha_{sim|C}, \alpha_{ident|V})$)"),
    "paircount_ident_new__paircountv_sim_newfamily:language" = TeX(r"($\rho(\alpha_{ident|C}, \alpha_{sim|V})$)"),
    "paircount_sim_new__paircountv_sim_newfamily:language" = TeX(r"($\rho(alpha_{sim|C}, \alpha_{sim|V})$)"),
    "paircountv_ident_new__paircountv_sim_newfamily:language" = TeX(r"($\rho(\alpha_{ident|V}, \alpha_{sim|V})$)")
  )
  
  p <- data %>% ggplot() +
    geom_density_ridges(
      aes(x = .value, y = var_name, color = type, fill = type, height = after_stat(density)),
      alpha = 0.7,
      stat = "density",
      trim = TRUE,
      scale = 0.8
    ) +
    xlim(-1, 1) +
    ggtitle(title) +
    coord_cartesian(clip = "off") +
    scale_y_discrete(labels = tex_labels) +
    theme(legend.title=element_blank()) +
    xlab(TeX(r"($\rho$ Value)")) +
    ylab("") +
    geom_vline(xintercept=0) +
    scale_color_manual(values=c(
      "#639EFE",
      "#732645",
      "#9FB783"
    )) +
    scale_fill_manual(values=c(
      "#639EFE",
      "#732645",
      "#9FB783"
    )) +
    theme(
      legend.position = 'bottom',
      legend.background = element_blank(),
      legend.box="vertical",
      text = element_text(family = "Fira Sans"),
      legend.text = element_text(family = "Fira Sans", size = 9)
    )
}

plot_priors <- function(data, title) {
  data <- data %>% filter(
    str_detect(type, "Prior")
  )
  
  tex_labels = c(
    "b" = TeX(r"($\beta$)"),
    "sd" = TeX(r"($\sigma)"),
    "cor" = TeX(r"($\rho)")
  )
  
  p <- data %>% ggplot() +
    geom_density_ridges(
      aes(x = .value, y = var_cat, height = after_stat(density)),
      alpha = 0.7,
      stat = "density",
      trim = TRUE,
      scale = 0.8,
      color = "#639EFE",
      fill = "#639EFE"
    ) +
    xlim(-10, 10) +
    geom_vline(xintercept=0) +
    ggtitle(title) +
    coord_cartesian(clip = "off") +
    scale_y_discrete(labels = tex_labels) +
    theme(legend.title=element_blank(),
          text = element_text(family = "Fira Sans"),
          legend.text = element_text(family = "Fira Sans", size = 9)) +
    xlab("Value") +
    ylab("")
}


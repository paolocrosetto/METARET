
# 
# 
# #### playground for the final plot -- commented away 
# 
# ## by treatment
# tests <- df %>% 
#   nest(-treatment) %>% 
#   mutate(
#     test = map(data, ~ cor.test(.x$perc, .x$soep, method = "pearson", conf.level = 0.95)), # S3 list-col
#     tidied = map(test, tidy)
#   ) %>% 
#   unnest(tidied, .drop = TRUE)
# 
# prova <- df %>% group_by(treatment) %>% summarise(N = n()) %>% left_join(tests, by = "treatment")
# 
# ## plot on non-transformed values
# prova %>% 
#   filter(treatment != "repeated") %>% 
#   mutate(p.value = cut(p.value, 
#                        breaks = c(-1, 0.01, 0.05, 0.1, 1), 
#                        labels = c("<1%", "<5%", "<10%", "n.s."))) %>% 
#   mutate(task = "BRET") %>% 
#   mutate(paper = "JRU2013") %>% 
#   mutate(treatment = paste(treatment, " (N = ", N, ")", sep ="")) %>% 
#   ggplot(aes(reorder(treatment,estimate), estimate, color= p.value))+
#   geom_errorbar(aes(ymin = conf.low , ymax = conf.high), width = 0.2)+
#    geom_point(size = 2)+
#    coord_flip()+
#    geom_hline(yintercept = 0, linetype = "dotted", color = "indianred")+
#    scale_color_manual(name = "significance", values = c("red", "orange", "yellow", "black"), drop = F)+
#    facet_grid(paper~task)
# ggsave("Bret_with_choices.png")
# 
# ## plot on implied r coefficients
# tests <- df %>% 
#   nest(-treatment) %>% 
#   mutate(
#     test = map(data, ~ cor.test(.x$r, .x$soep, method = "pearson", conf.level = 0.95)), # S3 list-col
#     tidied = map(test, tidy)
#   ) %>% 
#   unnest(tidied, .drop = TRUE)
# 
# prova <- df %>% group_by(treatment) %>% summarise(N = n()) %>% left_join(tests, by = "treatment")
# 
# prova %>% 
#   filter(treatment != "repeated") %>% 
#   mutate(p.value = cut(p.value, 
#                        breaks = c(-1, 0.01, 0.05, 0.1, 1), 
#                        labels = c("<1%", "<5%", "<10%", "n.s."))) %>% 
#   mutate(task = "BRET") %>% 
#   mutate(paper = "JRU2013") %>% 
#   mutate(treatment = paste(treatment, " (N = ", N, ")", sep ="")) %>% 
#   ggplot(aes(reorder(treatment,estimate), estimate, color= p.value))+
#   geom_errorbar(aes(ymin = conf.low , ymax = conf.high), width = 0.2)+
#   geom_point(size = 2)+
#   coord_flip()+
#   geom_hline(yintercept = 0, linetype = "dotted", color = "indianred")+
#   scale_color_manual(name = "significance", values = c("red", "orange", "yellow", "black"), drop = F)+
#   facet_grid(paper~task)
# ggsave("Bret_with_r.png")
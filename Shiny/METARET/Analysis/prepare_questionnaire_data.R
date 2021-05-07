preparedata <- function(df, quest) {
  df %>% 
    filter(!is.na({{quest}}))  %>% 
    mutate(subsample = case_when(paper == "Crosetto and Filippin EXEC 2016" ~ task,
                                 paper == "Crosetto and Filippin, JRU 2013" ~ treatment,
                                 paper == "Menkhoff and Sakha 2017" ~ "",
                                 TRUE ~ "")) %>% 
    mutate(subsample = paste0(paper, ' -- ', subsample)) %>% 
    select(subsample, subject, {{quest}}) %>% 
    distinct() %>% 
    group_by(subsample) %>% 
    mutate(m = mean({{quest}}, na.rm = T),
           sd = sd({{quest}}, na.rm = T),
           se = sd/sqrt(n()),
           ci = se * qt(.95/2 + .5, n()-1),
           cih = m+ci,
           cil = m-ci) %>% 
    mutate(n = n()) %>% 
    ungroup() %>% 
    mutate(subsample = paste0(subsample, " (N = ",n,")")) %>% 
    rename(choice = {{quest}})
}
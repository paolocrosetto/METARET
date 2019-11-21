library(tidyverse)
library(hrbrthemes)
library(gghighlight)
library(wesanderson)

theme_set(theme_ipsum_ps()+
            theme(legend.position = "none"))

df <- read_csv("Presentations/2019 11 22 - UiB Bergen/img/r_per_tutti_i_task.csv")

df <- df %>% rename(risklevel = X1) %>% 
  gather(task, cutoff, -risklevel) %>% 
  mutate(risklevel = as_factor(risklevel)) %>% 
  filter(task != "Balloon")

tasklist <- tibble(risklevel = 0.9, 
                   task = c("BRET", "HL", "EG", "CGP"),
                   cutoff = c(0.111, -0.37, -1, -0.645))

df %>% 
  ggplot(aes(risklevel, cutoff, group = task, color = task))+
  geom_line(size = 1.5)+
  geom_label(data = tasklist, aes(risklevel, cutoff, color = task, label = task), hjust = 1)+
  geom_hline(yintercept = 1, color = "grey50", linetype = "dashed")+
  # scale_color_manual(name = "", values = wes_palette("Darjeeling2", n = 4))+
  scale_color_brewer(name = "", palette = "Set1")+
  coord_cartesian(ylim = c(-1, 2.5), xlim = c(0.5,9.2))+
  scale_x_discrete(labels = c("1" = "no risk", "2" = "", "3" = "little\n risk", "4" = "",
                              "5" = "mid\n point", "6" = "", "7" = "high risk", "8" = "",
                              "9" = "all in"))+
  labs(title = "Implied CRRA risk parameter across tasks",
       x = "",
       y = "CRRA risk parameter")
  
ggsave("Presentations/2019 11 22 - UiB Bergen/img/Rmap.png", width = 8, height = 6, units = "in", dpi = 300)

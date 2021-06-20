
## Libraries
library(tidyverse)      ## basic data wrangling and plotting libraries
library(broom)          ## apply correlations to whole papers in one go
library(hrbrthemes)     ## cool ggplot theming
source("flat_violin.R") ## used for creating the 'raincloud' plot
library(ggbeeswarm)     ## quasirandom jitter
library(GGally)         ## correlation plot
library(RColorBrewer)   ## colors

## theming
theme_set(theme_minimal()+
            theme(legend.position = "bottom")+
            theme(strip.text.x = element_text(hjust = 0.5))+
            theme(panel.spacing.x = unit(0.2, "lines")))

## getting data -- dirty manual hack
df <- read_csv("df.csv",col_types = cols(
  .default = col_double(),
  bibkey = col_character(),
  paper = col_character(),
  task = col_character(),
  treatment = col_character(),
  inconsistent = col_logical(),
  key = col_character(),
  metabibkey = col_character(),
  soep_financial = col_double()
))

## functions to generate plots

# density by task 
plotDensity <- function(tasklist) {
  
  data <- df %>% 
    filter(r > -1.5 & r < 2.5) %>% 
    group_by(task) %>% 
    mutate(m = mean(r, na.rm = T),
           sd = sd(r, na.rm = T),
           se = sd/sqrt(n()),
           ci = se * qt(.95/2 + .5, n()-1),
           cih = m+ci,
           cil = m-ci) %>% 
    mutate(n = n()) %>% 
    ungroup() %>% 
    mutate(task = reorder(task,r))
  
  values <- c(rev(brewer.pal(length(levels(data$task)), "Set1")))
  names(values) <- levels(data$task)
  
  plot <- data %>% 
    mutate(task = paste0(task, " (N = ",n,")")) %>% 
    ggplot(aes(task, r, colour = task, fill = task)) +
    geom_flat_violin(position = position_nudge(x = 0.15, y = 0),
                     alpha = 0.7, 
                     adjust = 0.8,
                     scale = "width",
                     color = "white") +
    geom_point(alpha = 0.4,
               position = position_jitter(width = 0.12, height = 0),
               size = 0.8, show.legend = F, 
               shape = 21,
               color = "white") +  
    geom_boxplot(fill = 'white',
                 color = 'grey30',
                 width = 0.25,
                 outlier.alpha = 0,
                 alpha = 0) +
    # geom_errorbar(aes(ymin = cil, ymax = cih), width = 0.05, position = position_nudge(x = -0.2), show.legend = F)+
    # geom_point(aes(y = m), shape = 21, size = 2, position = position_nudge(x = -0.2), show.legend = F)+
    stat_summary(fun.data = mean_cl_boot, 
                 geom = "pointrange", position = position_nudge(x = - 0.2, y = 0),
                 show.legend = F)+
    geom_hline(yintercept = 1, color = 'red', linetype = 'dashed', show.legend = F)+
    labs(y = "risk aversion parameter r (CRRA, x*r)",
         x = "")+
    theme(legend.title = element_blank(),
          legend.position = "none")+
    coord_flip()
  
  plot %+% droplevels(data[data$task %in% tasklist,]) +
    scale_fill_manual(values = values)+
    scale_color_manual(values = values)
}


server <- function(input, output, session) {
  output$trend <- renderPlot({
    ggplot(subset(babynames, name == input$name)) + 
      geom_line(aes(x = year, y = prop, color = sex))
  })
  
  output$density_HL <- renderPlot({
    plotDensity("HL")
  })
  
  output$density_EG <- renderPlot({
    plotDensity("EG")
  })
  
  output$density_IG <- renderPlot({
    plotDensity("IG")
  })
  
  output$density_BRET <- renderPlot({
    plotDensity("BRET")
  })
  
  output$density_BART <- renderPlot({
    plotDensity("BART")
  })
  
  output$density_CEPL <- renderPlot({
    plotDensity("CPEL")
  })
  
  output$plot_top_10_names <- renderPlot({
    top_10_names <- babynames %>%
      filter(sex == input$sex) %>%
      filter(year == input$year) %>%
      top_n(10, prop)
    ggplot(top_10_names, aes(x = name, y = prop)) +
      geom_col(fill = "#263e63")
  })
  
  output$table_top_10_names <- DT::renderDT({
    top_10_names <- babynames %>%
      filter(sex == input$sex) %>%
      filter(year == input$year) %>%
      top_n(10, prop)
  })
}


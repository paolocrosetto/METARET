# density within versions of each task
task_variability_plot <- function(selectedtask, data) {
  
  sem <- function(x, na.rm = FALSE) {
    out <-sd(x, na.rm = na.rm)/sqrt(length(x))
    return(out)
  }
  
  ## Labelled with `citation` -- "Holt and Laury (2002)", "Pedroni et al.
  ## (2017)" -- built from the .bib in server.R. The old `paper` column was a
  ## free-text label each cleaning script wrote its own way: some had first
  ## names, some a journal ("Crosetto and Filippin, JRU 2013"), some the year
  ## without brackets, and the separator was sometimes "and", sometimes a comma.
  data %>% 
    filter(r > -1.5 & r < 2.5) %>% 
    select(r, citation) %>%
    drop_na() %>%
    group_by(citation)  %>%          # grouping variables
    summarize(m = mean(r),          # calculating mean 
              s = sem(r)) %>%    # calculating standard error
    ggplot(aes(m, reorder(citation,m), group = citation)) + 
    geom_line() +                       # adding connecting lines
    geom_errorbar(aes(xmin = m - s,     # adding lower error bars
                      xmax = m + s))+  # adding upper error bars
    geom_point(color = 'red', size = 3) +                      # adding data points
    labs(x = "Risk aversion parameter CRRA",
         y = "")+
    theme(legend.title = element_blank(),
          legend.position = "none")+
    scale_fill_brewer(palette = "Set1")+
    scale_color_brewer(palette = "Set1") + theme_bw() +
    #eliminates background, gridlines, and chart border
    theme(
      text = element_text(size = 16),
      plot.background = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank()
    ) +
    
    #draws x and y axis line
    theme(axis.line = element_line(color = 'black'))
}
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
  by_paper <- data %>%
    filter(r > -1.5 & r < 2.5) %>% 
    select(r, citation) %>%
    drop_na() %>%
    group_by(citation)  %>%          # grouping variables
    summarize(m = mean(r),          # calculating mean 
              s = sem(r))        # calculating standard error

  ## A reference line across the papers, so a single paper can be read against
  ## the task as a whole. It is the MEDIAN of the per-paper means, not their
  ## average: the per-paper means are few (four for CE_staircase, a hundred for
  ## HL) and skewed to the left, so one paper with an extreme mean moves the
  ## average by up to 0.09 (IG, CEPL) while barely touching the median.
  ## Nothing is hard-coded -- it is recomputed from whatever papers the task
  ## holds, so it shifts on its own as papers are added.
  task_median <- median(by_paper$m)

  by_paper %>%
    ggplot(aes(m, reorder(citation,m), group = citation)) + 
    geom_vline(xintercept = task_median, linetype = "dashed",
               colour = "#8A8A8A", linewidth = 0.6) +
    geom_line() +                       # adding connecting lines
    geom_errorbar(aes(xmin = m - s,     # adding lower error bars
                      xmax = m + s))+  # adding upper error bars
    geom_point(color = 'red', size = 3) +                      # adding data points
    labs(x = "Risk aversion parameter CRRA",
         y = "",
         ## the line is explained here rather than annotated next to itself,
         ## which ran off the panel whenever the median sat near the right edge
         subtitle = sprintf("dashed line: median of the papers' means = %.2f",
                            task_median))+
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
      panel.border = element_blank(),
      plot.subtitle = element_text(size = 13, colour = "#6E6E6E",
                                   margin = margin(b = 10))
    ) +
    
    #draws x and y axis line
    theme(axis.line = element_line(color = 'black'))
}
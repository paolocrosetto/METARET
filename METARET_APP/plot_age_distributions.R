## Drawing every dot is what made the age tabs slow: 1.1 s for the 87,672
## observations of "all tasks", 0.2 s for 20,000. The dots show a fixed random
## sample of at most AGE_POINT_CAP (the same one every time); the line, and
## the figures in the note under the plot, still use all observations. Shared
## with plot_age_distributions_quest.R, which is read after this file.
AGE_POINT_CAP <- 20000
age_points <- function(d) {
  if (nrow(d) <= AGE_POINT_CAP) return(d)
  d[withr::with_seed(20220823, sample(nrow(d), AGE_POINT_CAP)), , drop = FALSE]
}

## The rows both age panels plot and fit, the same for the figure and for the
## slope line under it: the answer y, age and paper, within the age range the
## user picked with the slider.
## Adults only used to be the rule here. Many of the contributed studies are
## run with schoolchildren and adolescents (Alan et al. 2019 from age 6.6,
## Roig et al. 2025 from 7, Aschenwald et al. 2024 and Alfonso et al. 2025
## from 10-11), so cutting at 18 hid about 13,000 observations. The bound of 5
## is a plausibility guard only: the youngest genuine subject in the whole
## dataset is 6.6, and the single value below that is one subject recorded as
## 2 years old in Engl et al. 2021, which cannot be a real age.
age_rows <- function(data, y, ages) {
  data %>%
    filter(age >= 5) %>%
    select(all_of(y), age, bibkey) %>%
    drop_na() %>%
    filter(age >= ages[1], age <= ages[2])
}

## How the answer changes per year of age within studies: each study's own
## mean age and mean answer are removed first, and one line is fitted through
## what is left, pooled over all studies (a regression with study fixed
## effects). Fitted on the raw values instead, the line would also pick up
## differences between studies -- student samples are young, panels and field
## samples older. With a single study this is the ordinary slope.
age_within_slope <- function(y, age, paper) {
  yy <- y - ave(y, paper); aa <- age - ave(age, paper)
  sum(aa * yy) / sum(aa^2)
}

## Rows too few, or all of one age, for a slope.
age_no_trend <- function(d) nrow(d) < 3 || stats::var(d$age - ave(d$age, d$bibkey)) == 0

## The explanatory note under each age plot, styled like the notes of the
## other tabs; the wording is the one validated for the site. The change is
## given across the ages actually plotted -- what the line does from its left
## end to its right end -- rather than per year. The ends are the youngest and
## oldest subject within the slider's range, not the slider's own ends: a task
## whose subjects are all 18-30 would otherwise be extrapolated over decades
## with no data. E.g.
##   "From age 6 to 99, r decreases by 0.12 after accounting for differences
##    between studies. ..."
## what: the answer as named in the sentence ("r", "the answer"); lab: the same
## in the list of steps ("r", "answer").
age_note <- function(d, y, what, lab) {
  note <- function(...) tags$div(class = "metaret-note", tags$b("Explanatory note:"), " ", ...)
  if (age_no_trend(d))
    return(note("Too few observations in this age range for a trend."))
  n <- nrow(d); G <- length(unique(d$bibkey))
  lo <- floor(min(d$age)); hi <- ceiling(max(d$age))
  v <- age_within_slope(d[[y]], d$age, d$bibkey) * (max(d$age) - min(d$age))
  change <- if (abs(v) < 0.005) "barely changes" else
    sprintf("%s by %.2f", if (v < 0) "decreases" else "increases", abs(v))
  shown <- if (n > AGE_POINT_CAP)
    sprintf("The plot displays %s randomly selected observations, while the trend estimation is calculated using the full sample.",
            format(AGE_POINT_CAP, big.mark = ","))
  else "The plot displays all of them."
  note(sprintf("From age %d to %d, %s %s after accounting for differences between studies.",
               as.integer(lo), as.integer(hi), what, change),
       " This estimate is calculated in three steps:",
       tags$ol(tags$li(sprintf("Calculate the average age and %s within each study.", lab)),
               tags$li(sprintf("Subtract these averages from each observation’s age and %s.", lab)),
               tags$li("Fit a single regression line using the resulting differences from all studies.")),
       sprintf("The analysis uses %s observations from %d stud%s. %s",
               format(n, big.mark = ","), G, if (G == 1) "y" else "ies", shown))
}

## The line drawn on the age plots: the within-study slope, drawn through the
## overall mean age and mean answer of the plotted rows, from the youngest to
## the oldest subject.
AGE_LINE <- "#FF8C00"
age_within_line <- function(d, y) {
  if (age_no_trend(d)) return(NULL)
  b <- age_within_slope(d[[y]], d$age, d$bibkey)
  x <- range(d$age)
  geom_segment(data = data.frame(x = x[1], xend = x[2],
                                 y = mean(d[[y]]) + b * (x[1] - mean(d$age)),
                                 yend = mean(d[[y]]) + b * (x[2] - mean(d$age))),
               aes(x = x, xend = xend, y = y, yend = yend), inherit.aes = FALSE,
               colour = AGE_LINE, linewidth = 1.4)
}

plotage <- function(selectedtask, data) {
data %>% ggplot(aes(x=age, y=r)) +
  geom_jitter(data = age_points(data), alpha = 0.5, color = '#87b0e8') +
  age_within_line(data, "r") +
  theme_bw() +
  #eliminates background, gridlines, and chart border
  theme(
    text = element_text(size = 16),
    plot.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    legend.title=element_blank(),
  ) + theme(axis.line = element_line(color = 'black')) +
  labs(x = "Age of respondents",
       y = "CRRA")
}

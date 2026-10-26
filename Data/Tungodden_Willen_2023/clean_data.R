#### Tungodden, J. & Willén, A. (2023).
#### When Parents Decide: Gender Differences in Competitiveness.
#### Journal of Political Economy, 131(3), 751-801.
#### https://doi.org/10.1086/721801
#### Data: Harvard Dataverse 10.7910/DVN/XKBJ0Q

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## 740 parent-child pairs recruited from middle schools within a two-hour
## drive of Bergen. The file stacks the pair: one row flagged `child` and one
## flagged `parent`, 1480 in all, with the pair-level columns repeated on
## both. All the children are in tenth grade and 15 years old; the parents
## average 46.
df <- read_dta("Data/Tungodden_Willen_2023/original_dataset.dta")
stopifnot(nrow(df) == 1480, sum(df$child) == 740, sum(df$parent) == 740)

## ONLY THE CHILDREN ARE KEPT. The parents faced the same gamble menu and the
## same 0-10 question, but both are framed about the child rather than
## themselves. The working-paper appendix gives the wording: "If you could
## give your child one of the following bonuses ... which would you choose?"
## and "When you make a choice for your child (the one participating in the
## experiment), are you generally willing to take risk". The paper calls these
## "parents' risk preferences over their children's outcomes". The data agree
## that the parent's own taste shows through -- fathers pick 2.41 of the five
## options against mothers' 2.02, while the child's gender makes no difference
## at all (2.18 for sons, 2.20 for daughters) -- but the stake is still
## someone else's, and risk taken on another's behalf is not the same object
## as the self-directed measures everywhere else on this site. Adding those
## 740 rows would be a one-line change if the project ever wants them.
##
## THE TASK is the Eckel and Grossman gamble choice, hypothetical: the
## children are told so in the question itself, "the bonus will not actually
## be paid to you", as they are minors. The site already carries a
## hypothetical menu for the same reason in the file for Alfonso et al.
## The five options and why the printed second one is a misprint are set out
## in the Tungodden2023 block of generate_r.R; in short, the other four are
## exactly 12.5 times the canonical Eckel and Grossman gambles, which fixes
## the second at 300/150 and makes the standard bounds apply.
## choice is the option number, 1 the sure amount and 5 the all-in gamble,
## which is this site's EG convention. The data confirm the ordering: average
## self-reported risk willingness climbs across the options, 4.72, 5.10, 5.86,
## 6.02, 6.77.
##
## THE SURVEY ITEM is the child's own general risk question in the standard
## wording: "How do you think about yourself? Are you a person who is
## generally willing to take risk, or do you try to avoid risk. Answer on a
## scale from 0 to 10, where 0 means 'not willing to take risk at all', and 10
## means 'very willing to take risk'."
##
## Both are complete for all 740 and both run the usual way: on the gambles
## boys average 2.65 against girls' 2.14, on the survey item 5.72 against 5.11.
df <- df %>%
  filter(child == 1) %>%
  transmute(subject = row_number(),
            task = "EG",
            choice = as.numeric(risk),
            soep = as.numeric(risk_q),
            gender = as.numeric(girl),
            ## the paper: the children "are all in tenth grade and are 15
            ## years old"; no age column is published
            age = 15,
            bibkey = "Tungodden2023",
            paper = "Tungodden and Willen 2023")
stopifnot(nrow(df) == 740, !any(is.na(df$choice)), !any(is.na(df$soep)))

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Fifteen middle schools spread around Bergen in Hordaland county; the
## schools themselves are anonymised, so no single city fits.
df$country = 'Norway'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Tungodden_Willen_2023/formatted_dataset.csv")

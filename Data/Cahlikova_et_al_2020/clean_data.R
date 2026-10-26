#### Cahlíková, J., Cingl, L. & Levely, I. (2020).
#### How Stress Affects Performance and Competitiveness Across Gender.
#### Management Science, 66(8), 3295-3310.
#### https://doi.org/10.1287/mnsc.2019.3400
#### Data: Harvard Dataverse 10.7910/DVN/IQIPSI

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## 190 students from several elite universities in Prague, run in z-Tree at
## the Laboratory of Experimental Economics there across 2014 and 2015, with
## psychosocial stress induced in half the sessions by the Trier Social Stress
## Test. The risk elicitation is Task 7, which comes after the stress
## manipulation and the competition tasks.
df <- read_dta("Data/Cahlikova_et_al_2020/original_dataset.dta")
stopifnot(nrow(df) == 190)

## THE TASK. A sure amount against a 50/50 lottery is this site's CEPL. The
## paper: "a series of choices between a lottery, which paid CZK 240 or 0 with
## 50% probability each, and a safe payment. The safe payment varied across
## choices, gradually increasing from CZK 0 to CZK 240 in steps of CZK 20."
## The file keeps no row-by-row answers, only CertaintyEquivalent, but that
## column is the midpoint of the switching interval and the step is 20, so the
## row at which the subject first took the safe payment is CE/20 + 1.5, an
## exact inversion.
##
## WHO IS DROPPED. 14 subjects switched more than once and the authors already
## set their certainty equivalent to missing; the Inconsistent flag marks
## exactly those 14. A further 5 are coded 250, which is above the top safe
## payment and means they took the lottery even when offered a sure 240 --
## that is weakly dominated, since 240 is also the best the lottery can pay,
## so no increasing utility function rationalises it and there is no upper
## bound to place them at. Both groups keep their questionnaire answers under
## quest_only and only lose the task, leaving 171 CEPL observations.
##
## THE QUESTIONNAIRE. The study ran the full Dohmen et al. battery, general
## plus five domains; the site carries the general item (soep) and the
## financial one (soep_financial), and the other four -- driving, sports,
## career and health -- have no column here. Both kept items are complete for
## all 190 and run the usual way: for the general question men average 5.95
## against women's 5.03, for the financial one 5.04 against 3.64. The task
## agrees: men's certainty equivalent averages 127.0 against women's 106.9.
##
## Female is already 1 for women, and the sample is exactly balanced, 95 each.
df <- df %>%
  mutate(ce = as.numeric(CertaintyEquivalent),
         usable = !is.na(ce) & ce < 250,
         switch_row = if_else(usable, ce / 20 + 1.5, NA_real_))
stopifnot(sum(df$usable) == 171,
          all(df$switch_row[df$usable] == round(df$switch_row[df$usable])))

df <- df %>%
  transmute(subject = row_number(),
            task = if_else(usable, "CEPL", "quest_only"),
            ## for the 19 without a usable switch point the row is a
            ## questionnaire row, and generate_data_for_app.R moves `choice`
            ## into `soep`, so the general item goes there
            choice = if_else(usable, switch_row, as.numeric(Risk_1)),
            soep = as.numeric(Risk_1),
            soep_financial = as.numeric(Risk_3),
            gender = as.numeric(Female),
            age = as.numeric(age),
            bibkey = "Cahlikova2020",
            paper = "Cahlikova et al. 2020")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data.
## get_r is only called on the CEPL rows: the questionnaire rows have no
## branch in generate_r.R, and their `choice` is the survey answer, not a
## switching row.
source("Data/generate_r.R")
df$r <- NA_real_
i <- df$task == "CEPL"
df$r[i] <- purrr::pmap_dbl(list(df$bibkey[i], df$task[i], df$choice[i]), get_r)

## Laboratory of Experimental Economics, University of Economics, Prague.
df$country = 'Czech Republic'
df$city = 'Prague'
df$lattitude = '50.0833'
df$longitude = '14.4406'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Cahlikova_et_al_2020/formatted_dataset.csv")

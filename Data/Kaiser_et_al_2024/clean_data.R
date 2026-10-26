#### Kaiser, J. P., Koch, A. K. & Nafziger, J. (2024).
#### Does goal revision undermine self-regulation through goals? An experiment.
#### Experimental Economics, 27(3), 604-636.
#### https://doi.org/10.1007/s10683-024-09826-0
#### Data: Dataverse 10.7910/DVN/49LVAT

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## An online real-effort study on goal setting, run with the subject pool of
## the COBElab at Aarhus University and, during the covid lockdown, students
## from the four largest Danish cities. The published ReplicationData file is
## long, 1394 rows over 395 subjects; the survey answers are constant within a
## subject, so one row each was copied here for the 394 who have a risk
## answer. That is exactly the number the paper gives: of 499 recruited, "394
## completed the date-0 part of the study".
df <- read_csv("Data/Kaiser_et_al_2024/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 394)

## WHY quest_only: the experiment elicits goals for a transcription task and
## how much the subject then works; there is no lottery anywhere in it. The
## readme calls the column plainly, "risk: self-reported risk tolerance".
##
## The wording is the standard one, recovered from the Qualtrics file
## (GoalrevisionPart1.qsf, QID269): "How do you see yourself? Are you
## generally a person who is fully prepared to take risks or do you try to
## avoid taking risks? Please select a value between 0 and 10, where the value
## 0 means 'not at all willing to take risks' and the value 10 means 'very
## willing to take risks'." So it is the Dohmen item on its usual scale.
## Nobody picked 0 and one subject picked 1, which fits a sample sitting well
## to the right: the mode is 7 and the mean 6.2.
##
## GENDER IS NOT IN THE PUBLISHED FILE. The instructions say it was asked --
## subjects answer "questions ... related to your background (e.g., gender,
## age, and study area)" -- but no such column survives the anonymisation, so
## it stays missing here. Age does survive, 18 to 77, with a mean of 24.7.
df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(risk),
            gender = NA_real_,
            age = as.numeric(age),
            bibkey = "Kaiser2024",
            paper = "Kaiser et al. 2024")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## Online across Denmark: the pool is the COBElab at Aarhus University plus
## students in the four largest Danish cities, so no single city fits.
df$country = 'Denmark'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kaiser_et_al_2024/formatted_dataset.csv")

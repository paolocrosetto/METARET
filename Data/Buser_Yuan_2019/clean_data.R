#### Buser, T. & Yuan, H. (2019).
#### Do Women Give Up Competing More Easily? Evidence from the Lab and the
#### Dutch Math Olympiad.
#### American Economic Journal: Applied Economics, 11(3), 225-252.
#### https://doi.org/10.1257/app.20170160
#### Data: openICPSR 10.3886/E116353V1

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## Three laboratory experiments at the CREED lab of the University of
## Amsterdam, run from November 2015: the "main" one with 188 subjects, the
## "feedback" one with 184 and the "risk" one with 188, 560 in all. The
## companion file matholympiad.dta is the field part of the paper and carries
## no risk measure, so only the lab file is used.
df <- read_dta("Data/Buser_Yuan_2019/original_dataset.dta")
stopifnot(nrow(df) == 560)

## WHY quest_only. The third experiment does make subjects choose repeatedly
## between a piece rate and a risky scheme that pays off with probability x,
## fixed per subject at 0.3, 0.4, 0.5, 0.6 or 0.7 (the Cutoff column, and
## nrrisky counts the risky choices over five rounds). That is not an
## elicitation here: the payoff of both schemes depends on the subject's own
## output in a real-effort task, the design mirrors the tournament-entry
## choice of the other two experiments rather than a lottery menu, and the
## count is the paper's dependent variable -- the question being asked is
## whether women stop choosing the risky scheme after losing. It is also only
## available for a third of the sample.
##
## What every subject answered is the general risk question, quoted in the
## paper in its usual form: "How do you see yourself: Are you generally a
## person who is fully prepared to take risks or do you try to avoid taking
## risks?" (Dohmen et al.), "on a scale from 0 ('unwilling to take risks') to
## 10 ('fully prepared to take risk')". No answer is missing.
##
## GENDER. The variable carries no value labels, but the do-file settles it:
## the summary loop writes `sum ... if Gender==1` into the column it names "m"
## and `if Gender==2` into the one it names "f". The paper's own table then
## confirms it three times over -- risk taking of 5.5 overall, 6.0 for men and
## 5.0 for women in the main experiment, 5.4 / 5.6 / 5.1 in the feedback one,
## and a footnote giving 5.6 against 4.5 in the risk experiment -- and all six
## numbers come back exactly. Over the whole sample men average 5.71 against
## women's 4.87, the usual direction.
df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(Risk),
            gender = case_when(Gender == 2 ~ 1, Gender == 1 ~ 0,
                               TRUE ~ NA_real_),
            age = as.numeric(Age),
            bibkey = "Buser2019",
            paper = "Buser and Yuan 2019")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## CREED, University of Amsterdam.
df$country = 'Netherlands'
df$city = 'Amsterdam'
df$lattitude = '52.3600'
df$longitude = '4.9089'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Buser_Yuan_2019/formatted_dataset.csv")

#### Novak, V., Matveenko, A. & Ravaioli, S. (2024).
#### The Status Quo and Belief Polarization of Inattentive Agents:
#### Theory and Experiment.
#### American Economic Journal: Microeconomics, 16(4), 1-39.
#### https://doi.org/10.1257/mic.20210352
#### Data: openICPSR 10.3886/E193622V1

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The package publishes no table of risk choices: the Holt-Laury menu sits
## inside the per-subject MATLAB session files, one per participant, in the
## field HL_select. extract_from_mat.py in this folder pulls it out together
## with the prizes and the questionnaire columns, and writes the csv read
## below; the dataset README documents the same quantity under
## SP_HoltLaury_Summary, "count in how many rows (out of 11) the safe option
## was chosen".
##
## The experiment ran at CELSS, Columbia University, between August and
## September 2019, with 85 participants in all. HL_select exists only for
## participants 23 to 85, the same 63 who have the questionnaire: the price
## list and the questionnaire were both added to the protocol from that
## participant onward.
df <- read_csv("Data/Novak_et_al_2024/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 63)

## The program filled the blanks around the switching point, so single
## crossing is enforced and holds: 60 subjects switch once and 3 sit at a
## corner (two take the risky side in every row, one the safe side in every
## row). Those corners also cross a dominated row -- row 1 pays $1.75 for sure
## against $0.10 for sure, row 11 pays $2.00 for sure against $4.00 -- and the
## bounds block gives them the end points, as the canonical Holt-Laury block
## does for its own corners.
stopifnot(all(df$switches <= 1))

## GenderDummy is 1 for women: matching the clean file to the raw answers on
## the participant id gives 43 Female at 1, 17 Male at 0 and the 3 who
## preferred not to say at NA. Age is self-reported, 18 to 42, one missing.
##
## A direction note. The usual check fails here, and it is not a coding slip:
## women take the risky side 5.28 times on average against men's 4.41
## (p = 0.138, and p = 0.005 once the three corner subjects are set aside),
## while the self-reported risk scale in the same questionnaire runs the usual
## way, 2.04 for men against 1.67 for women. With 17 men the task comparison
## rests on very little, and the gender gap is known to be weaker in Holt-Laury
## than in survey items.
##
## The questionnaire's own RISK_Scale is left out: it is a bespoke average of
## three agreement items on 0 to 4 ("I often take risk just for fun", "I take
## risk only if it is necessary to achieve an important goal", "I avoid
## activities whose results depend too much on chance"), not one of the
## instruments this site carries. It correlates 0.14 with the menu (p = 0.30).
df <- df %>%
  transmute(subject = ParticipantID,
            task = "HL",
            choice = n_risky,
            gender = as.numeric(GenderDummy),
            age = as.numeric(Age),
            bibkey = "Novak2024",
            paper = "Novak et al. 2024")

## Columbia Experimental Laboratory for Social Sciences, Columbia University,
## New York.
df$country = 'United States'
df$city = 'New York'
df$lattitude = '40.8075'
df$longitude = '-73.9626'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Novak_et_al_2024/formatted_dataset.csv")

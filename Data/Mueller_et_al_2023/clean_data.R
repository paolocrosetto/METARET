#### Müller, M., Olsen, J., Kirchler, E. & Kogler, C. (2023).
#### How explicit expected value information affects tax compliance decisions
#### and information acquisition.
#### Journal of Economic Psychology, 99, 102679.
#### https://doi.org/10.1016/j.joep.2023.102679
#### Data: https://osf.io/v56rn

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## An online tax-compliance experiment on Prolific. 345 participants made 24
## compliance decisions each (8280 observations, as the supplementary material
## reports) and answered a Holt and Laury list afterwards.
##
## Two files are kept here: original_dat.csv, the analysis file with one row per
## participant and decision, and original_risk_aversion.csv, the raw risk task
## with the ten rows as separate columns r1 ... r10 holding "A" or "B".
dat  <- read_csv("Data/Mueller_et_al_2023/original_dat.csv", show_col_types = FALSE)
risk <- read_csv("Data/Mueller_et_al_2023/original_risk_aversion.csv", show_col_types = FALSE)

## The raw risk file has 467 rows for 436 people -- 28 of them appear twice --
## and covers more people than the analysis sample, so it is made unique first
## and then joined onto the 345 participants of the analysis file.
rows <- paste0("r", 1:10)
risk <- risk %>%
  distinct(subject_id, .keep_all = TRUE)

B <- as.matrix(risk[, rows]) == "B"

## `choice` is the number of rows where the risky option B was taken, which is
## this site's convention for HL. The authors' own risk_HL is the first row with
## a B, that is the switch row; for a subject who switches once the two agree as
## 11 - risk_HL, and that identity holds for all 286 such subjects here, which
## is what fixed the reading of their variable.
##
## Only subjects whose answers are A's followed by B's are kept: a list with the
## B's scattered does not identify a switch point. That leaves 296 of 345. The
## ten subjects who took A in all ten rows are kept with choice = 0, as the HL
## blocks of generate_r.R do throughout, even though A is dominated in the last
## row.
risk <- risk %>%
  mutate(nrisky = rowSums(B, na.rm = TRUE),
         nmiss  = rowSums(is.na(B)),
         mono   = apply(B, 1, function(v) {
           if (any(is.na(v))) return(NA)
           k <- sum(v)
           identical(as.logical(v), c(rep(FALSE, 10 - k), rep(TRUE, k)))
         }))

## Sex is spelled out; the site codes 1 for women. Age comes from the Prolific
## record and has no gaps. The self-reported risk item (risk_item) is in the
## file too, but the package shows the questionnaire only as screenshots, so its
## wording and scale could not be checked and it is left out.
df <- dat %>%
  distinct(ID, .keep_all = TRUE) %>%
  inner_join(risk %>% select(subject_id, nrisky, nmiss, mono),
             by = c("ID" = "subject_id")) %>%
  filter(nmiss == 0, mono) %>%
  arrange(ID) %>%
  transmute(subject = row_number(),
            task = "HL",
            choice = nrisky,
            gender = case_when(Sex == "Female" ~ 1, Sex == "Male" ~ 0, TRUE ~ NA_real_),
            age = as.numeric(age.prolific),
            bibkey = "Mueller2023",
            paper = "Müller et al. 2023")

## online on Prolific. The package does not record residence, but the paper
## (section 2.1) set the Prolific prescreen to "UK nationality", so the sample is
## United Kingdom (by nationality, not checked residence)
df$country = 'United Kingdom'
df$city = ''
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Mueller_et_al_2023/formatted_dataset.csv")

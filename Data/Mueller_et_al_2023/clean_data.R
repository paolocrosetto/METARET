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
source("Data/inconsistent_rows.R")
risk <- risk %>%
  distinct(subject_id, .keep_all = TRUE)

B <- as.matrix(risk[, rows]) == "B"

## `choice` is the number of rows where the risky option B was taken, which is
## this site's convention for HL. The authors' own risk_HL is the first row with
## a B, that is the switch row; for a subject who switches once the two agree as
## 11 - risk_HL, and that identity holds for all 286 such subjects here, which
## is what fixed the reading of their variable.
##
## Only subjects whose answers are A's followed by B's, with B in row 10, enter
## the statistics: a list with the B's scattered does not identify a switch
## point, and A in the last row is dominated. That leaves 286 of 345 (the ten
## who took A in all ten rows were counted with choice = 0 until 29.10.2026).
## The others with a complete list are kept for the download only, with
## inconsistent = 1 and one row per switch to B (Data/inconsistent_rows.R).
risk <- risk %>%
  mutate(nrisky = rowSums(B, na.rm = TRUE),
         nmiss  = rowSums(is.na(B)),
         mono   = apply(B, 1, function(v) {
           if (any(is.na(v))) return(NA)
           k <- sum(v)
           identical(as.logical(v), c(rep(FALSE, 10 - k), rep(TRUE, k)))
         }),
         points = lapply(seq_len(nrow(B)), function(i) switch_points(as.numeric(B[i, ]))))

## Sex is spelled out; the site codes 1 for women. Age comes from the Prolific
## record and has no gaps. The self-reported risk item (risk_item) is in the
## file too, but the package shows the questionnaire only as screenshots, so its
## wording and scale could not be checked and it is left out.
df <- dat %>%
  distinct(ID, .keep_all = TRUE) %>%
  inner_join(risk %>% select(subject_id, nrisky, nmiss, mono, points),
             by = c("ID" = "subject_id")) %>%
  filter(nmiss == 0) %>%
  arrange(ID) %>%
  transmute(subject = row_number(),
            task = "HL",
            points,
            inconsistent = as.numeric(!mono | nrisky == 0),
            gender = case_when(Sex == "Female" ~ 1, Sex == "Male" ~ 0, TRUE ~ NA_real_),
            age = as.numeric(age.prolific),
            bibkey = "Mueller2023",
            paper = "Müller et al. 2023") %>%
  ## choice = number of B choices = 11 - the row where B starts
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))
stopifnot(sum(df$inconsistent == 0) == 286)

## online on Prolific. The package does not record residence, but the paper
## (section 2.1) set the Prolific prescreen to "UK nationality", so the sample is
## United Kingdom (by nationality, not checked residence)
df$country = 'United Kingdom'
df$city = ''
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Mueller_et_al_2023/formatted_dataset.csv")

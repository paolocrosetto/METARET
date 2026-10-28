#### Cipriani, M., Fostel, A. & Houser, D. (2018). Collateral constraints and the
#### law of one price: An experiment. The Journal of Finance.
#### https://doi.org/10.1111/jofi.12722
#### Data: the journal's supporting information (Replication Code: holt_laury.dta
#### and the market data, do-files, readme; the Internet Appendix), kept in
#### raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "The experiment was run at the Interdisciplinary Center for Economic Science
## (ICES) at George Mason University ... seven sessions ... for an overall total of
## 88 subjects." The session codes date the sessions from June to October 2016.
## holt_laury.dta has one row per subject (session, subject).
##
## Task: Holt and Laury (2002) with the original payoffs (A = $2.00 / $1.60,
## B = $3.85 / $0.10; Internet Appendix Table IAI), after the market; "subjects
## were paid ... on average $3 in the elicitation phase". holt_a = number of safe
## (A) choices; switch = 1 for the 26 subjects with more than one switching point,
## whom the authors also set aside (appendix.do), so they are left out here.
## choice = number of B choices = 10 - holt_a.
##
## Gender and age are not in the files.
df <- read_csv("Data/Cipriani_et_al_2018/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 88, sum(df$switch == 1) == 26)

df <- df %>%
  filter(switch == 0) %>%
  transmute(subject = row_number(),
            task = "HL",
            choice = 10 - holt_a,
            age = NA_real_,
            gender = NA_real_,
            country = "United States",
            city = "Fairfax",
            bibkey = "Cipriani2018",
            paper = "Cipriani et al. 2018")

## the map is drawn by country; the coordinates are those of the university
df$lattitude = '38.8316'
df$longitude = '-77.3089'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Cipriani_et_al_2018/formatted_dataset.csv")

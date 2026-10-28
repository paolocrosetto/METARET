#### Schaap, R.-J. (2021). The prevalence of prudence in a risky occupation.
#### Economics Letters, 207, 110019. https://doi.org/10.1016/j.econlet.2021.110019
#### Data: heiDATA 10.11588/data/GV8NBL, the NATCOOP project dataset
#### (NATCOOP_dataverse_files.zip: Natcoop_Master.dta, codebook, scripts)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The paper uses the second NATCOOP field trip to Chile (CL2), "between October
## 30 and November 23 of 2018 ... 26 sessions in 11 landing sites", small-scale
## fishers in the Biobío and Valparaíso regions. Natcoop_Master.dta holds all five
## NATCOOP field trips (Chile 2017-2018, Tanzania 2017-2020); only the CL2 rows
## (v002 Chile, v001 2018) are kept: 460 fishers (the paper's 423 are those who
## also completed the prudence task). 82 of them had taken part in CL1 in 2017;
## as CL1 is not used, nobody is counted twice.
##
## Task: Gneezy-Potters, "distribute 6 points between a safe option, with a
## certain payout of 1 point per invested point, and a risky option. The points
## in the risky option were either lost or tripled, each with 50% probability"
## (paper; procedural script CL1). e003 = points in the risky option.
##
## q001 is age; q002 gender, 1 = female (codebook). The session coordinates are
## those of the landing site (v006, v007), the place of the workshop.
df <- read_csv("Data/Schaap_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 460, all(df$risky_points %in% 0:6))

df <- df %>%
  transmute(subject = row_number(),
            task = "IG",
            choice = risky_points,
            age,
            gender = gender_code,
            country = "Chile",
            city = comuna,
            lattitude = as.character(round(latitude, 4)),
            longitude = as.character(round(longitude, 4)),
            bibkey = "Schaap2021",
            paper = "Schaap 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Schaap_2021/formatted_dataset.csv")

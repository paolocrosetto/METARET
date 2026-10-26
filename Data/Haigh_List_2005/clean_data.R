#### Haigh, M. S. & List, J. A. (2005). Do professional traders exhibit myopic loss aversion?
#### An experimental analysis. Journal of Finance, 60(1), 523-534.
#### https://doi.org/10.1111/j.1540-6261.2005.00737.x
#### Data: from the collection of Harrison and Rutström (2008), "Risk Aversion in the
#### Laboratory" (CEAR, https://cear.gsu.edu/files/2016/07/Risk-Aversion-in-the-Laboratory.zip)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## HLdata.dta (folder haigh_list), one row per subject and round: 64 University of
## Maryland undergraduates and 54 CBOT futures and options traders.
## Gneezy-Potters design: nine rounds, 100 units per round, p_bet = % bet; with
## probability 1/3 the bet gains 2.5 times its value (up to 350 units per round),
## with 2/3 it is lost.
## freq: 1 = Treatment F (decide and see the outcome every round),
##       3 = Treatment I (one bet for three rounds at a time).
## Only Treatment F, round 1 (lottery == 1, before any feedback) is kept,
## as for Gneezy1997, Schwaiger2025 and Hueber2022.
## student: 1 = student (College Park, MD), 0 = trader (CBOT, Chicago).
## No demographics in the file.
df <- read_csv("Data/Haigh_List_2005/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  filter(freq == 1, lottery == 1) %>% 
  transmute(subject = row_number(),
            task = "IG",
            choice = p_bet,
            country = "United States",
            city = if_else(student == 1, "College Park", "Chicago"))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Haigh2005",
         paper = "Haigh and List 2005")

## no coordinates added (as for the other new papers)
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Haigh_List_2005/formatted_dataset.csv")

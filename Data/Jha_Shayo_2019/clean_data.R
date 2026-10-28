#### Jha, S. & Shayo, M. (2019). Valuing peace: The effects of financial market
#### exposure on votes and political attitudes. Econometrica, 87(5), 1561-1588.
#### https://doi.org/10.3982/ECTA16385
#### Data: the journal's supplementary data and programs (replicationdata.dta,
#### do-files, readme; Appendix B), kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "A month and a half prior to the highly contested 2015 Israeli elections, we
## randomly assigned 1345 Jewish Israeli voters" from an internet panel that "is
## nationally representative in terms of age and sex"; one row each (uid),
## recruited in two waves.
##
## No risk task in the data. The baseline survey asked "How do you see yourself?
## Are you generally a person who is fully prepared to take risks or do you try
## to avoid taking risks?" The paper gives the scale as 1 to 10, but
## willingrisk1to10 runs 0-10 (49 answers of 0), the 11-point scale of Dohmen et
## al. (2011), and is taken as such. It goes into soep as a questionnaire-only
## row.
##
## male: 1 = man; age in years.
df <- read_csv("Data/Jha_Shayo_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 1345, all(df$willingrisk1to10 %in% 0:10))

df <- df %>%
  transmute(subject = uid,
            task = "quest_only",
            ## for questionnaire-only rows generate_data_for_app.R moves
            ## choice into soep
            choice = willingrisk1to10,
            r = NA_real_,
            gender = if_else(male == 1, 0, 1),
            age,
            country = "Israel",
            city = "")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Jha2019",
         paper = "Jha and Shayo 2019")

## a nationwide online panel, so no study location
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Jha_Shayo_2019/formatted_dataset.csv")

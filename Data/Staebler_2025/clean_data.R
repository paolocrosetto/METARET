#### Staebler, J. (2025). Disclosure policy in contests with sabotage and group
#### size uncertainty. European Economic Review, 179, 105120.
#### https://doi.org/10.1016/j.euroecorev.2025.105120
#### Data: OSF, https://doi.org/10.17605/OSF.IO/VS8WZ (Replication_Files.zip)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online Tullock-contest experiment with the subject pool of the Mannheim
## Laboratory for Experimental Economics (sessions run over Zoom, 17 sessions,
## 196 subjects; the author drops one who lost the connection, leaving the 195
## analysed in the paper). original_dataset.csv is Data/data.csv of the
## replication package -- one row per analysed subject -- reduced to the risk
## measure and the demographics; the contest rounds are not used here.
##
## Risk task (Section 2 of the experiment, Table A.14 of the author's
## dissertation): a ten-row price list, each row the same lottery -- 50% of 0
## cents, 50% of 50 cents -- against a sure payment of 5, 10, ..., 50 cents.
## One row of one of the three lists (risk, loss, ambiguity) was paid.
## The author's risk_aversion counts rows from the first one in which the sure
## payment was chosen, so the switch row is 11 - risk_aversion; choice is that
## switch row, 1 (switched at 5 cents, most averse) to 10 (only at 50 cents).
##
## multiple_switching flags the subjects who went back to the lottery after
## switching, read off the per-session files in Data/Raw_Data. A single switch
## is what brackets the certainty equivalent, so the 4 subjects who switched
## more than once are out of the statistics and 191 remain. The 4 are kept for
## the download only, with inconsistent = 1 (Data/inconsistent_rows.R): the file
## has only the author's count, which starts at their first switch, so each has
## one row with that first switch as choice.
df <- read_csv("Data/Staebler_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            task = "CEPL",
            choice = 11 - risk_aversion,
            inconsistent = as.numeric(multiple_switching == 1),
            age,
            gender = if_else(gender == "female", 1, 0),
            country = "Germany",
            city = "Mannheim")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Staebler2025",
         paper = "Staebler 2025")

df$lattitude = '49.4875'
df$longitude = '8.4660'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Staebler_2025/formatted_dataset.csv")

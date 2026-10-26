
### Collects every formatted_dataset.csv into the single table the app reads,
### then rebuilds the precomputed correlation panels. Run from the repository
### root, which is what every path below is relative to:
###
###     Rscript Data/generate_data_for_app.R
library(tidyverse)

## getting data from all the "formatted_dataset.csv" files in each subdirectory of /Data
df <- list.files(recursive = T, pattern = "^formatted_dataset") %>% 
  map_dfr(read_csv)

df = df %>% filter(task != 'quest_only' | is.na(task) == TRUE) %>% 
  full_join(df %>% filter(task == 'quest_only') %>% 
              mutate(soep = choice,
                     choice = NA)) 


## Each clean_data.R writes its own `paper` label, so the year arrived in
## parentheses in about half of them and bare in the rest -- visible in the
## app's paper lists and in the README table. The year always sits at the end,
## so wrapping a bare one is enough; a label that already has its own
## parentheses (Lange 2007a, 2007b) ends in ")" and is left alone.
## "et al" was written both with and without the stop -- 30 labels one way, 13
## the other. `\\.?` swallows the stop when it is already there, so the rule is
## safe to re-run and cannot produce "et al..".
df <- df %>%
  mutate(paper = str_squish(paper),
         paper = str_replace(paper, ",?\\s*(\\d{4}[a-z]?)\\s*$", " (\\1)"),
         paper = str_replace_all(paper, "\\bet\\s+al\\b\\.?", "et al."),
         ## a couple of labels joined two surnames with the French "et".
         ## This runs after the line above, so every "et al." already has its
         ## stop and the lookahead leaves it alone.
         paper = str_replace_all(paper, "\\bet\\s+(?!al\\.)", "and "),
         ## six labels carried the journal (or, for Holzmeister and Stefan, the
         ## publication status) inside the author string. The year already tells
         ## Crosetto and Filippin's two papers apart, so nothing is lost by
         ## dropping it -- checked: the 87 labels stay 87, no two collide.
         paper = str_remove(paper, regex(paste0("\\s*,?\\s*(EXEC|JRU|JEBO|PONE|",
                                              "Science Advances|Working Paper)\\b"))),
         paper = str_squish(paper))

data=df %>% mutate(subject = paste0(bibkey, '_', subject)) %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, starts_with('soep'),
                starts_with('do'), 'BIS', 'BSSS', 'AuditS', 'CDCrisk', country, city,
         longitude, lattitude)

## save the df to the shiny director for deployment
data %>% write_csv("METARET_APP/DATA/df_mod.csv")

## The years each paper's data were gathered in, which are not the publication
## years df carries. The master copy is edited here, in Data/, but the app is
## deployed from METARET_APP/ alone, so it needs its own copy next to df_mod.csv
## or the map tooltip silently loses the collection period once uploaded.
file.copy("Data/collection_years.csv", "METARET_APP/DATA/collection_years.csv",
          overwrite = TRUE)

## rebuild the precomputed correlation panels the app serves, so they can never
## go stale relative to df_mod.csv above
source("Data/build_corr_cache.R")

## and the meta-analysis tables, for the same reason -- they are not read by the
## app, but leaving them to be refreshed by hand is how they fell behind before.
## Costs about a second of a two-second rebuild, none of it in the app.
source("Data/build_analysis_tables.R")



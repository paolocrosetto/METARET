library(bib2df) 
library(tidyverse)

# import the bibfile
bibdf <- bib2df("Bib/METARET.bib")

## clean the bibfile
## keep the authors, title, journal, year, DOI

# clean names
bibdf <- bibdf %>% 
  janitor::clean_names() %>% 
  rename(bibkey = bibtexkey)


# export to csv




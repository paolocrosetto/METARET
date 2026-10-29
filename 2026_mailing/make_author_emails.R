#### METARET -- emails to the authors whose open data are in METARET
####
#### Reads outreach/author_emails.xlsx, sheet "papers" (one row per paper),
#### and writes:
####   - the sheet "emails" of the same file: one row per email (to, subject, body),
####     which outreach/send_author_emails.R sends;
####   - one .txt per email in outreach/emails/, to read through.
#### 
####
#### One email per corresponding author (the `to` column); an author with several
#### papers gets a single email listing them all, each with its own link to the
#### form, so every answer is still tied to one paper.
####
#### What the email asks the authors is the column `request` of the sheet
#### "papers", edited there: a phrase that follows "We could not find in the
#### package or the paper ..." (e.g. "the age of the participants"), or a request
#### starting with "confirm that ..." that becomes a question. Empty: nothing asked.
####
#### Run from the metaret-main folder:  Rscript outreach/make_author_emails.R

#### libraries
library(tidyverse)
library(readxl)
library(writexl)
library(glue)

#### settings
## the Tally form; the paper and the person written to go into its hidden fields
## (doi, bibkey, title, name, email), so every answer comes back tied to its paper
form_url <- "https://tally.so/r/o991QM"
site_url <- "https://paolocrosetto.shinyapps.io/METARET_APP/"

emails_file <- "outreach/author_emails.xlsx"
out_dir     <- "outreach/emails"

#### getting the data
papers <- read_excel(emails_file, sheet = "papers", col_types = "text")
## Paolo's own papers get no email; their sheet is kept as it is
own <- read_excel(emails_file, sheet = "Paolo's papers")

#### pieces of the email
form_link <- function(doi, bibkey, title, name, email) {
  enc <- function(x) URLencode(coalesce(x, ""), reserved = TRUE)
  doi <- str_remove(str_to_lower(doi), "^https?://(dx\\.)?doi\\.org/")
  glue("{form_url}?doi={enc(doi)}&bibkey={enc(bibkey)}&title={enc(title)}",
       "&name={enc(name)}&email={enc(email)}")
}

## what we took from the package
data_lines <- function(p, indent) {
  c(if (!is.na(p$task))          glue("{indent}- risk elicitation task: {p$task}"),
    if (!is.na(p$questionnaire)) glue("{indent}- questionnaire: {p$questionnaire}"),
    glue("{indent}- participants: {p$participants}",
         if (is.na(p$country)) "" else glue(", {p$country}"))) %>%
    paste(collapse = "\n")
}

## the request as a sentence; `form` is "the same form" or "its form"
ask_sentence <- function(request, form) {
  if (is.na(request)) return(NA_character_)
  if (str_starts(request, "confirm "))
    return(glue("Could you {request}? You can answer in the comment field of {form}."))
  glue("We could not find in the package or the paper {request}. If you have it and ",
       "are happy to share it, {form} has a comment field and one for files.")
}

intro <- function(name) glue(
"Dear {coalesce(name, 'colleague')},

I am Paolo Crosetto, an experimental economist at GAEL (INRAE, Université Grenoble Alpes). With Elizaveta Golovanova (CRESE, University of Marie and Louis Pasteur) I run METARET, an open database that brings together the data of studies that measure risk attitudes with lottery tasks and questionnaires. The aim is to see how well these measures agree with each other across many samples. You can explore it here: {site_url}")

outro <-
"Thanks a lot, and thank you for making your data public. This is what makes a project like METARET possible.

Best,
Paolo

--
Paolo Crosetto
GAEL, INRAE, Université Grenoble Alpes
paolo.crosetto@inrae.fr"

#### the email: one paper, or several
body_one <- function(name, p) {
  a <- ask_sentence(p$request, "the same form")
  paste(c(
    intro(name),
    glue(
"While collecting data we found the replication package of your paper

  {p$title} ({p$journal}, {p$year})
  {p$doi}

which is openly available. We have formatted it for METARET, and it is now part of the public dataset on the website. This is what we took from it:

{data_lines(p, '  ')}

Your paper is cited as the source wherever these data appear.

I would like to make sure that you are fine with it. We found the packages of many authors, so handling the answers by email would be hard; we set up a short form instead (about one minute):

  {p$link}"),
    if (!is.na(a)) paste("If you agree, there is one more thing.", a),
    outro), collapse = "\n\n")
}

body_many <- function(name, ps) {
  ps <- ps %>% mutate(i = row_number(), a = map_chr(request, ask_sentence, form = "its form"))
  blocks <- map_chr(seq_len(nrow(ps)), function(k) {
    p <- ps[k, ]
    glue(
"{p$i}. {p$title} ({p$journal}, {p$year})
   {p$doi}
{data_lines(p, '   ')}
   Form for this paper: {p$link}")
  })
  ## the requests come after the paragraph on the form, so that "if you agree" and
  ## "its form" are already explained
  asks <- ps %>% filter(!is.na(a))
  ask_par <- if (nrow(asks) == 1)
    glue("If you agree, there is one more thing about paper {asks$i} (\"{asks$title}\"). {asks$a}") else
    if (nrow(asks) > 1)
    paste0("If you agree, there is one more thing about ", nrow(asks), " of these papers:\n\n",
           paste0("- Paper ", asks$i, " (\"", asks$title, "\"): ", asks$a, collapse = "\n"))
  paste(c(
    intro(name),
    glue("While collecting data we found the replication packages of {nrow(ps)} of your papers, which are openly available. We have formatted them for METARET, and they are now part of the public dataset on the website. Below, for each paper, is what we took from it and its own link to the form:"),
    blocks,
    "Your papers are cited as the source wherever these data appear.",
    "I would like to make sure that you are fine with it. We found the packages of many authors, so handling the answers by email would be hard; we set up a short form instead (about one minute per paper, with one link for each paper above).",
    ask_par,
    outro), collapse = "\n\n")
}

#### building the emails
emails <- papers %>%
  mutate(link = form_link(doi, bibkey, title, name, to)) %>%
  group_by(to) %>%
  summarise(ps = list(pick(everything())), .groups = "drop") %>%
  mutate(name     = map_chr(ps, ~ .x$name[1]),
         n_papers = map_int(ps, nrow),
         bibkeys  = map_chr(ps, ~ paste(.x$bibkey, collapse = ", ")),
         subject  = map_chr(ps, ~ if (nrow(.x) == 1)
                      glue("METARET and the data of your paper \"{.x$title}\"") else
                      "METARET and the data of your papers"),
         body     = map2_chr(name, ps, ~ if (nrow(.y) == 1) body_one(.x, .y) else body_many(.x, .y)),
         has_question = map_lgl(ps, ~ any(!is.na(.x$request))))

#### writing to file
unlink(out_dir, recursive = TRUE)
dir.create(out_dir, recursive = TRUE)
walk2(emails$body, emails$bibkeys,
      ~ write_file(.x, file.path(out_dir, paste0(str_replace_all(.y, ", ", "_"), ".txt"))))

write_xlsx(list(papers = papers,
                emails = emails %>% select(to, name, n_papers, bibkeys, subject, body, has_question),
                `Paolo's papers` = own),
           emails_file)

cat(nrow(emails), "emails for", nrow(papers), "papers,",
    sum(emails$n_papers > 1), "of them cover several papers,",
    sum(emails$has_question), "with a question\n")

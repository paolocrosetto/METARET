## Precomputes the table the app reads, METARET_APP/DATA/app_data.rds: the
## rows of df_mod.csv joined with the bibliography (authors in house style,
## citation labels with a/b for same-surname-same-year papers, title, year,
## journal, DOI, URL). Doing this in server.R -- parsing the .bib, formatting
## 657 entries and merging them into 180,000 rows -- cost about 3.4 s at every
## app start; reading the rds takes a fraction of a second.
## Run by generate_data_for_app.R; on its own, from the repository root:
##     Rscript Data/build_app_data.R

suppressMessages({
  library(tidyverse)
  library(bib2df)
  library(data.table)
})

read_bib_unwrapped <- function(path) {
  ln   <- readLines(path, warn = FALSE)


  cont <- grepl("^[ \t]+\\S", ln) & !grepl("^\\s*[A-Za-z_]+\\s*=", ln)
  out  <- character(0)
  for (i in seq_along(ln)) {
    if (cont[i] && length(out)) {
      out[length(out)] <- paste0(out[length(out)], " ", trimws(ln[i]))
    } else {
      out <- c(out, ln[i])
    }
  }

  bare <- grepl('^\\s*[A-Za-z_]+\\s*=\\s*[^{"\\s][^,]*,?\\s*$', out, perl = TRUE)
  out[bare] <- sub('^(\\s*[A-Za-z_]+\\s*=\\s*)([^{"\\s][^,]*?)(,?)\\s*$',
                   '\\1{\\2}\\3', out[bare], perl = TRUE)

  tmp <- tempfile(fileext = ".bib")
  writeLines(out, tmp)
  tmp
}
## bib2df warns that entries "may have been dropped" and that YEAR is
## character: both come from the two JabRef @Comment blocks, which have no
## fields. Checked: all 657 entries parse and every bibkey of df_mod.csv has
## its row. bib2df sends them as messages; only those two are muffled, so any
## other message or warning still shows.
bib_noise <- "may have been dropped|contains character strings"
bibdf <- withCallingHandlers(
  bib2df(read_bib_unwrapped("METARET_APP/METARET.bib")),
  message = function(m) {
    if (grepl(bib_noise, conditionMessage(m))) invokeRestart("muffleMessage")
  },
  warning = function(w) {
    if (grepl(bib_noise, conditionMessage(w))) invokeRestart("muffleWarning")
  })

## clean names
bibdf <- bibdf %>% 
  janitor::clean_names() %>% 
  rename(bibkey = bibtexkey)

## keep the authors, title, journal, year, DOI
if (!"doi_2" %in% names(bibdf)) bibdf <- bibdf %>% rename(doi_2 = doi)
## bib2df leaves the outer braces on some fields whatever we do, so trim them.
unbrace <- function(x) {
  if (is.list(x)) return(lapply(x, unbrace))
  x <- as.character(x)
  x <- sub('^\\s*\\{+\\s*', '', x)
  x <- sub('\\s*\\}+\\s*$', '', x)
  x
}
bibdf <- bibdf %>% mutate(across(c(title, journal, year, url), unbrace))

## ---------------------------------------------------------------- authors ---
## bib2df hands back one character vector of names per paper, each written the
## way its .bib entry happened to write it -- "Erkal, Nisvan" in one entry,
## "Jürgen Huber" in the next -- and DT then pasted the vector with a bare
## comma, so the site showed "Jürgen Huber,Stefan Palan,Stefan Zeisberger".
## These three helpers put every paper into one house style:
##
##     one author     Holt, C.
##     two            Holt, C. and Laury, S.
##     three          Erkal, N., Gangadharan, L. and Koh, B. H.
##     four or more   Pedroni, A., Frey, R., Bruhin, A. et al.

delatex <- function(x) {
  map <- c(
    'a"'="ä", 'o"'="ö", 'u"'="ü", 'A"'="Ä", 'O"'="Ö", 'U"'="Ü", 'e"'="ë", 'i"'="ï",
    "a'"="á", "e'"="é", "i'"="í", "o'"="ó", "u'"="ú", "c'"="ć", "n'"="ń", "s'"="ś", "z'"="ź",
    "A'"="Á", "E'"="É", "I'"="Í", "O'"="Ó", "U'"="Ú", "C'"="Ć", "N'"="Ń", "S'"="Ś",
    "a`"="à", "e`"="è", "i`"="ì", "o`"="ò", "u`"="ù",
    "a^"="â", "e^"="ê", "i^"="î", "o^"="ô", "u^"="û",
    "a~"="ã", "n~"="ñ", "o~"="õ", "N~"="Ñ",
    "cc"="ç", "cC"="Ç", "vs"="š", "vS"="Š", "vc"="č", "vC"="Č", "vz"="ž", "vZ"="Ž"
  )
  for (nm in names(map)) {
    letter <- substr(nm, 1, nchar(nm) - 1)
    cmd    <- substr(nm, nchar(nm), nchar(nm))
    if (cmd %in% c("c", "v")) { letter <- substr(nm, 2, 2); cmd <- substr(nm, 1, 1) }
    ## all four spellings LaTeX allows: {\"u}  \"{u}  \"u  {\"{u}}
    pat <- paste0("\\{?\\\\", "\\", cmd, "\\s*\\{?", letter, "\\}?\\}?")
    x <- gsub(pat, map[[nm]], x, perl = TRUE)
  }
  x <- gsub("\\{?\\\\ss\\}?", "ß", x, perl = TRUE)
  x <- gsub("\\{?\\\\o\\}?",  "ø", x, perl = TRUE)
  x <- gsub("\\{?\\\\aa\\}?", "å", x, perl = TRUE)
  x <- gsub("[{}\\\\]", "", x)         
  trimws(gsub("\\s+", " ", x))
}

## "Andreas C." -> "A. C." ; "C.A." -> "C. A." ; "Jean-Louis" -> "J.-L."
initials_of <- function(given) {
  toks <- Filter(nzchar, unlist(strsplit(given, "\\s+")))
  if (!length(toks)) return("")
  paste(vapply(toks, function(t) {
    if (grepl("^([A-Za-z]\\.){2,}$", t)) {           # already initials, no spaces
      ls <- unlist(strsplit(gsub("\\.", "", t), ""))
      return(paste(paste0(toupper(ls), "."), collapse = " "))
    }
    parts <- Filter(nzchar, unlist(strsplit(t, "-")))
    paste(paste0(toupper(substr(parts, 1, 1)), "."), collapse = "-")
  }, character(1)), collapse = " ")
}

## Dutch/German/Romance particles stay with the surname: "Roel van Veldhuizen"
## is van Veldhuizen, R., not Veldhuizen, R. v.
NAME_PARTICLES <- c("van", "von", "de", "del", "della", "der", "den", "di", "da",
                    "dos", "du", "la", "le", "ten", "ter", "vander", "van't", "y")

split_name <- function(a) {
  a <- delatex(a)
  if (!nzchar(a)) return(c(surname = "", given = ""))
  if (grepl(",", a, fixed = TRUE)) {                  # "Last, First M."
    return(c(surname = trimws(sub(",.*$", "", a)),
             given   = trimws(sub("^[^,]*,", "", a))))
  }
  toks <- Filter(nzchar, unlist(strsplit(a, "\\s+")))   # "First M. Last"
  if (length(toks) == 1) return(c(surname = toks, given = ""))
  i <- length(toks)
  while (i > 1 && tolower(toks[i - 1]) %in% NAME_PARTICLES) i <- i - 1
  c(surname = paste(toks[i:length(toks)], collapse = " "),
    given   = paste(toks[seq_len(i - 1)], collapse = " "))
}

one_author <- function(a) {
  p <- split_name(a)
  if (!nzchar(p[["surname"]])) return("")
  ini <- initials_of(p[["given"]])
  if (nzchar(ini)) paste0(p[["surname"]], ", ", ini) else p[["surname"]]
}


format_citation <- function(x, year) {
  sur <- Filter(nzchar, vapply(as.character(x),
                               function(a) split_name(a)[["surname"]],
                               character(1), USE.NAMES = FALSE))
  yr  <- gsub("\\D", "", as.character(year))
  yr  <- if (nzchar(yr)) paste0(" (", substr(yr, 1, 4), ")") else ""
  n <- length(sur)
  if (n == 0) return(NA_character_)
  if (n == 1) return(paste0(sur, yr))
  if (n == 2) return(paste0(sur[1], " and ", sur[2], yr))
  paste0(sur[1], " et al.", yr)
}

format_authors <- function(x) {
  if (is.null(x) || (length(x) == 1 && (is.na(x) || !nzchar(x)))) return(NA_character_)
  names_ <- Filter(nzchar, vapply(as.character(x), one_author, character(1),
                                  USE.NAMES = FALSE))
  n <- length(names_)
  if (n == 0) return(NA_character_)
  if (n == 1) return(names_)
  if (n == 2) return(paste(names_, collapse = " and "))
  if (n == 3) return(paste0(paste(names_[1:2], collapse = ", "), " and ", names_[3]))
  paste0(paste(names_[1:3], collapse = ", "), " et al.")
}

bibs <- bibdf %>%
  mutate(citation = purrr::map2_chr(author, year, format_citation),
         author   = vapply(author, format_authors, character(1))) %>%
  select(bibkey, author, citation, title, year, journal, doi_2, url)

## fread and a data.table join, much faster than read.csv + merge(). The
## rows are then put in exactly the order merge() used to give them (by bibkey
## as base R sorts it, and within a paper merge()'s own order), worked out on
## the key alone so the app sees the same table it always did.
app_df <- fread("METARET_APP/DATA/df_mod.csv")
app_df[, row_in_csv := .I]
row_order <- merge(data.frame(bibkey = app_df$bibkey, row_in_csv = app_df$row_in_csv),
                   data.frame(bibkey = bibs$bibkey), by = "bibkey", all.x = TRUE)$row_in_csv
app_df <- as.data.table(bibs)[app_df[row_order], on = "bibkey"]
setcolorder(app_df, c(setdiff(names(app_df), names(bibs)), setdiff(names(bibs), "bibkey")))
setcolorder(app_df, "bibkey")
app_df[, row_in_csv := NULL]

## two papers with the same first author and year read "Lange (2007)" twice;
## the second becomes "Lange (2007b)" and so on, in bibkey order
cites <- unique(app_df[, .(bibkey, citation)])[order(bibkey)]
cites[, citation := if (.N == 1) citation
                    else paste0(sub("\\)$", "", citation), letters[seq_len(.N)], ")"),
      by = citation]
app_df[, citation := NULL]
app_df <- merge(app_df, cites, by = "bibkey", all.x = TRUE, sort = FALSE)

saveRDS(as.data.frame(app_df), "METARET_APP/DATA/app_data.rds")

## Helpers for inconsistent answers to multiple price lists, shared by the
## clean_data.R scripts.
##
## The site's statistics use only consistent answers. Inconsistent ones -- a
## list answered with more than one switch, or a dominated choice -- are kept
## for the download with inconsistent = 1 and r empty (generate_data_for_app.R
## and METARET_APP/consistent_rows.R). A subject who switched several times
## gets one row per switch to the riskier option, numbered by switch_no, and
## each row's choice is coded exactly as a consistent subject who switched at
## that point would be coded in that paper.

## a: one subject's answers in list order, 1 = the option that is taken from
## the switching row on (the riskier one in a Holt-Laury list), 0 = the other.
## Returns the rows at which that option starts: row 1 if it is taken from the
## first row, and every later row k with a[k] == 1 and a[k - 1] == 0. A
## subject who never takes it has no switching point.
switch_points <- function(a) unname(which(diff(c(0, unname(a))) == 1))

## TRUE for a list answered with at most one switch, and only in the expected
## direction (0 ... 0 1 ... 1)
single_switch <- function(a) all(diff(a) >= 0)

## Expands the inconsistent subjects of d into one row per switching point.
## d: one row per subject with a list-column `points` (switch_points of their
## answers); to_choice: the paper's coding of a switch at row k into choice.
## A subject with no switching point (the option was never taken) keeps one
## row, with the choice that coding gives for "never" (to_choice(NA)).
expand_switches <- function(d, to_choice) {
  d %>%
    mutate(points = purrr::map(points, function(p) if (length(p) == 0) NA_integer_ else as.integer(p)),
           .row = row_number()) %>%
    tidyr::unnest_longer(points) %>%
    group_by(.row) %>%
    mutate(choice = to_choice(points),
           ## numbered only for inconsistent subjects: a consistent one has a
           ## single row and switch_no stays empty
           switch_no = if_else(inconsistent == 1, as.numeric(row_number()), NA_real_)) %>%
    ungroup() %>%
    select(-points, -.row)
}

## r for the consistent rows only, in their order. get_r() draws from one
## seeded stream (generate_r.R), so calling it on inconsistent rows as well
## would shift every later draw; this way a paper whose inconsistent subjects
## used to be dropped keeps exactly the r values it had. Inconsistent rows get
## no r (generate_data_for_app.R would empty it anyway).
consistent_r <- function(df) {
  ok <- df$inconsistent == 0
  r <- rep(NA_real_, nrow(df))
  r[ok] <- purrr::pmap_dbl(list(df$bibkey[ok], df$task[ok], df$choice[ok]), get_r)
  r
}

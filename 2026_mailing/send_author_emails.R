#### METARET -- sending the emails written by outreach/make_author_emails.R
####
#### Reads outreach/author_emails.xlsx (sheet "emails": one row per email) and
#### sends each body as a plain-text email from Paolo's address over SMTP.
####
#### Three modes, set in `mode` below:
####   "dry_run" (default)  sends NOTHING: writes every email as a .eml file in
####                        outreach/outbox/, to open and check in a mail program
####   "test"               sends the first `n_test` emails to `test_to` only,
####                        with "[TEST]" in the subject; no author gets anything
####   "send"               sends to the authors. Runs only if `confirm` below is
####                        set to exactly "SEND TO AUTHORS". At most
####                        `max_per_run` emails per run, `pause_seconds` apart;
####                        every email sent is logged in outreach/sent_log.csv and
####                        never sent twice, so the script can be run again to
####                        continue where it stopped.
####
#### The password is never written in this file: it is read from the environment
#### variable METARET_SMTP_PASSWORD, e.g. in the terminal
####   export METARET_SMTP_PASSWORD='...'
####   Rscript outreach/send_author_emails.R
####
#### Run from the metaret-main folder, after make_author_emails.R.

#### libraries
library(tidyverse)
library(readxl)
library(curl)
library(base64enc)

#### settings
mode     <- "dry_run"                   # "dry_run", "test" or "send"
confirm  <- ""                          # "SEND TO AUTHORS" to allow mode = "send"

from_address <- "paolo.crosetto@inrae.fr"
from_name    <- "Paolo Crosetto"
## the outgoing mail server of that address and its login. INRAE: smtp.inrae.fr,
## port 587, STARTTLS, login = the full address, the usual INRAE password (as in
## the account settings of a mail program; ask the IT service if it is refused).
## "smtp://...:587" with use_ssl = "force" switches to TLS before logging in.
smtp_server  <- "smtp://smtp.inrae.fr:587"
smtp_user    <- from_address
use_ssl      <- "force"

## optional: a copy of every email, e.g. to keep them all in one mailbox
bcc          <- character(0)

test_to       <- ""                     # the address that gets the test emails
n_test        <- 3
max_per_run   <- 40
pause_seconds <- 20

emails_file <- "outreach/author_emails.xlsx"
outbox_dir  <- "outreach/outbox"
log_file    <- "outreach/sent_log.csv"

#### getting the emails
emails <- read_excel(emails_file, sheet = "emails") %>%
  filter(!is.na(to), to != "")

#### building a message
## headers with accents (names, titles) are encoded as RFC 2047 words; the body
## is UTF-8 text in base64, so accents and long lines travel unchanged
enc_header <- function(x) {
  if (!str_detect(x, "[^\\x01-\\x7F]")) return(x)
  paste0("=?UTF-8?B?", base64encode(charToRaw(enc2utf8(x))), "?=")
}
make_message <- function(to, subject, body) {
  b64 <- base64encode(charToRaw(enc2utf8(body)))
  b64 <- paste(str_sub(b64, seq(1, nchar(b64), 76), pmin(seq(76, nchar(b64) + 75, 76), nchar(b64))),
               collapse = "\r\n")
  paste0(
    "From: ", enc_header(from_name), " <", from_address, ">\r\n",
    "To: ", to, "\r\n",
    "Subject: ", enc_header(subject), "\r\n",
    "Date: ", format(Sys.time(), "%a, %d %b %Y %H:%M:%S %z"), "\r\n",
    "Message-ID: <", format(Sys.time(), "%Y%m%d%H%M%OS6"), ".", sample.int(1e9, 1),
    "@metaret>\r\n",
    "MIME-Version: 1.0\r\n",
    "Content-Type: text/plain; charset=UTF-8\r\n",
    "Content-Transfer-Encoding: base64\r\n",
    "\r\n", b64, "\r\n")
}

send_one <- function(to, subject, body) {
  password <- Sys.getenv("METARET_SMTP_PASSWORD")
  if (password == "") stop("METARET_SMTP_PASSWORD is not set")
  send_mail(mail_from = from_address, mail_rcpt = c(to, bcc),
            message = make_message(to, subject, body),
            smtp_server = smtp_server, use_ssl = use_ssl, verbose = FALSE,
            username = smtp_user, password = password)
}

#### dry run: nothing is sent
if (mode == "dry_run") {
  dir.create(outbox_dir, showWarnings = FALSE, recursive = TRUE)
  pwalk(list(emails$to, emails$subject, emails$body, emails$bibkeys),
        function(to, subject, body, bibkeys)
          write_file(make_message(to, subject, body),
                     file.path(outbox_dir, paste0(str_replace_all(bibkeys, ", ", "_"), ".eml"))))
  cat("DRY RUN: nothing sent.", nrow(emails), "emails written to", outbox_dir, "\n")
  quit(save = "no")
}

#### test: only to test_to
if (mode == "test") {
  if (test_to == "") stop("set test_to before a test run")
  t <- head(emails, n_test)
  for (i in seq_len(nrow(t))) {
    send_one(test_to, paste("[TEST]", t$subject[i]), t$body[i])
    cat("test", i, "of", nrow(t), "sent to", test_to, "(would go to", t$to[i], ")\n")
    if (i < nrow(t)) Sys.sleep(pause_seconds)
  }
  quit(save = "no")
}

#### send: to the authors
if (mode != "send") stop("mode must be \"dry_run\", \"test\" or \"send\"")
if (confirm != "SEND TO AUTHORS") stop("mode = \"send\" needs confirm <- \"SEND TO AUTHORS\"")

sent <- if (file.exists(log_file)) read_csv(log_file, show_col_types = FALSE) else
  tibble(to = character(), bibkeys = character(), time = character(), status = character())
todo <- emails %>%
  filter(!to %in% sent$to[sent$status == "sent"]) %>%
  head(max_per_run)
cat(nrow(todo), "emails to send in this run;",
    nrow(emails) - sum(emails$to %in% sent$to[sent$status == "sent"]) - nrow(todo),
    "left for later runs\n")

for (i in seq_len(nrow(todo))) {
  status <- tryCatch({
    send_one(todo$to[i], todo$subject[i], todo$body[i])
    "sent"
  }, error = function(e) paste("error:", conditionMessage(e)))
  sent <- bind_rows(sent, tibble(to = todo$to[i], bibkeys = todo$bibkeys[i],
                                 time = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
                                 status = status))
  write_csv(sent, log_file)
  cat(i, "/", nrow(todo), todo$to[i], "-", status, "\n")
  if (i < nrow(todo)) Sys.sleep(pause_seconds)
}

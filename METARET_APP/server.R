## packages for the project
source("libraries.R")

## df: the rows of df_mod.csv joined with the bibliography (house-style
## authors, citation labels, title, year, journal, DOI, URL). Built once by
## Data/build_app_data.R when the data are rebuilt, instead of parsing the .bib
## and merging at every start, which took about 3.4 s.
df <- readRDS("DATA/app_data.rds")

## the plotting functions and the task / questionnaire description tables,
## read once at start-up (they were re-read on every redraw)
for (f in c("plot_lotteries.R", "plot_many_lotteries.R", "function_each_type_of_task.R",
            "plot_questionnaires.R", "plot_gender_distributions.R",
            "plot_gender_distributions_quest.R", "plot_age_distributions.R",
            "plot_age_distributions_quest.R", "description.R", "description_quest.R"))
  source(f)

corr_cache <- readRDS("DATA/corr_cache.rds")


corr_full_palette <- function(n = 200) COL2('PiYG', n)

corr_matrix_panel <- function(m, symmetric = FALSE) {
  if (symmetric && identical(rownames(m), colnames(m))) diag(m) <- NA
  rownames(m) <- formatC(rownames(m), width = CORR_LABEL_W)

  d       <- dev.size("in") * 72        # the canvas in CSS pixels
  cell    <- corr_cell(m, d[1], d[2])
  cex_sc  <- max(0.55, min(1.25, cell / CORR_REF_CELL))


  lim <- CORR_LIM

  rng  <- suppressWarnings(range(m, na.rm = TRUE))
  sym  <- CORR_SYM
  if (all(is.finite(rng))) sym <- max(sym, abs(rng))   # never clip, never error
  plot_lim <- c(-sym, sym)


  withCallingHandlers(
  corrplot(m, method = 'color',
           type   = if (symmetric) "lower" else "full",
           diag   = !symmetric,
           tl.pos = "lt",
           col.lim = plot_lim,
           is.corr = FALSE,    # honour col.lim instead of assuming [-1, 1]
           addCoef.col = 'black',
           tl.col = 'black',
           col = corr_full_palette(),
           na.label = "  ",
           tl.srt = 45,        # horizontal, the questionnaire names collide
           number.cex = 1.15 * cex_sc,
           tl.cex = 1.10 * cex_sc,
           mar = if (symmetric) CORR_MAR_SYM else CORR_MAR,
           tl.offset = 0.5,
           cl.pos = "n"),
    warning = function(w) {
      if (grepl("col.lim interval too wide", conditionMessage(w), fixed = TRUE))
        invokeRestart("muffleWarning")
    },
    message = function(mm) {
      if (grepl("col.lim interval too wide", conditionMessage(mm), fixed = TRUE))
        invokeRestart("muffleMessage")
    })

}

CORR_OV_W     <- 150                      # room for the row labels
CORR_OV_H     <- 150                      # the angled column labels need height.
CORR_MAR      <- c(3.5, 0.5, 0.5, 2)
CORR_MAR_SYM  <- c(5, 0.5, 0.5, 2)        # bottom, left, top, right (lines)
CORR_LIM      <- c(-0.3, 0.7)             # what the colour bar shows
CORR_SYM      <- 0.7                      # what corrplot colours over: +/- this
CORR_MIN_COLS <- 2                        # a 1-wide selection still looks like a matrix
CORR_CELL_MAX <- 110                      # see the note on jumping, below
CORR_LABEL_W  <- max(nchar(c(corr_cache$task_cols, corr_cache$quest_cols)))
CORR_REF_CELL <- 62                       # the cell the text sizes were chosen for
CORR_CHROME_H <- 138                      # header and the tab strip above it
                                          # (the note and the button below the
                                          # figure are allowed to scroll)

corr_cell <- function(m, avail_w, avail_h = NULL) {
  cols <- max(ncol(m), CORR_MIN_COLS)
  max(14, min(CORR_CELL_MAX, (avail_w - CORR_OV_W) / cols))
}
corr_panel_width <- function(m, avail_w, avail_h = NULL) {
  max(ncol(m), CORR_MIN_COLS) * corr_cell(m, avail_w) + CORR_OV_W
}
corr_panel_height <- function(m, avail_w, avail_h = NULL) {
  nrow(m) * corr_cell(m, avail_w) + CORR_OV_H
}


value_box <- function(subtitle, value, ...) {

  if (is.data.frame(value) && nrow(value) == 1 && ncol(value) == 1) {
    value <- value[[1]]
  }
  if (is.numeric(value)) {
    value <- format(value, big.mark = " ", trim = TRUE, scientific = FALSE)
  }
  semantic.dashboard::value_box(subtitle, value, ...)
}

## Function to create links in the table
createLink <- function(doi, url = NA_character_) {
  doi <- sub("^\\s*(https?://(dx\\.)?doi\\.org/|doi:\\s*)", "", trimws(doi),
             ignore.case = TRUE)
  href <- if (!is.na(doi) && nzchar(doi)) paste0("http://dx.doi.org/", doi)
          else if (!is.na(url) && nzchar(url)) url
          else return("")
  sprintf('<a href="%s" target="_blank" class="btn btn-primary">Click</a>', href)
}

## Names of the graphics function
colnames_given_pattern <- function(.data, pattern){
  suppressWarnings(names(.data)[stringr::str_detect(.data, pattern)])
}

## ---------------------------------------------------------- download ---
## The single download file (see the Download page in server()), built once
## per R process rather than once per visitor.
dump_quest <- c("soep", "soep_financial", "soep_patience", "soep_impulsive",
                "doall", "dohealth", "dosocial", "doinvest", "dogamble",
                "doethic", "dorecre", "BIS", "BSSS", "AuditS", "CDCrisk")
dump_years <- tryCatch(
  readr::read_csv("DATA/collection_years.csv", show_col_types = FALSE) %>%
    select(bibkey, collected_from = year_from, collected_to = year_to),
  error = function(e) tibble(bibkey = character(),
                             collected_from = integer(), collected_to = integer()))
dump <- df %>%
  left_join(dump_years, by = "bibkey") %>%
  transmute(bibkey, paper = citation, authors = author,
            pub_year = as.integer(year), journal, doi = as.character(doi_2),
            country, city, collected_from, collected_to,
            subject, gender, age,
            task = if_else(task == "quest_only", "none", task), choice, r,
            across(all_of(dump_quest))) %>%
  arrange(bibkey, subject, task)
dump_view <- dump %>% mutate(r = round(r, 3))   # what the preview table shows

## ------------------------------------------------------------------ map ---
## Everything the map needs depends only on the data, so it is built once per
## R process here instead of once per visitor inside server() (about 0.5 s
## of every session went to joining the world polygons and computing their
## areas and label points). Visitors all get the same finished widget.

data(world, package = "spData")
world_map <- world %>% rename(name = name_long)

## The dataset spells countries the way the papers do; spData's polygons use
## a handful of different names, so translate before the join or the country
## silently falls off the map.
to_polygon <- c("Russia" = "Russian Federation")

## Two different spans of years go into the tooltip, and they must not be
## confused with each other.
##
## The tooltip shows WHEN THE DATA WERE GATHERED, which is not the `year`
## df carries -- that is the publication year, merged in from the
## bibliography, and fieldwork precedes it by a year or more, sometimes by a
## decade (Di Falco and Vieider's Ethiopian panel ran 2013-2017 and was
## published in 2022). The publication years are deliberately not shown at
## all: a collection period can line up with a drought, a crisis, a lockdown
## or a reform, which is what makes a country's level worth a second look,
## and a publication date cannot.
##
## The periods live in Data/collection_years.csv, one row per paper, each
## with the sentence it was read from, and are filled in paper by paper --
## so far for a minority of them. So the line is printed over the papers
## whose period is known, with the count when that is only some of them.
collection <- tryCatch(
  readr::read_csv("DATA/collection_years.csv", show_col_types = FALSE),
  error = function(e) tibble::tibble(bibkey = character(),
                                     year_from = integer(),
                                     year_to = integer()))

span <- function(lo, hi) {
  lo <- suppressWarnings(min(lo, na.rm = TRUE))
  hi <- suppressWarnings(max(hi, na.rm = TRUE))
  if (!is.finite(lo) || !is.finite(hi)) return(NA_character_)
  if (lo == hi) as.character(lo) else paste0(lo, "-", hi)
}

## How many observations a country needs before it is coloured at all. Ten
## countries sit on one to four people each -- Croatia, Kazakhstan and
## Slovakia on a single one, Finland on two -- almost all of them lone
## respondents of online panels whose nationality happened to be recorded.
## Painting a whole country from one person says nothing about that country
## and reads as if it did, so below this they stay grey like a country with
## no data. The count is still in the tooltip, with the reason, so the
## observations are not hidden -- only the colour is withheld.
min_obs <- 50
isTRUE_vec <- function(x) !is.na(x) & x

countries = df %>%
  filter(r > -1.5 & r < 2.5) %>%
  left_join(collection %>% select(bibkey, year_from, year_to), by = "bibkey") %>%
  group_by(country) %>%
  summarise(CRRA = mean(r),
            Observartions = n(),
            Collected = span(year_from, year_to),
            n_papers = n_distinct(bibkey),
            n_dated = n_distinct(bibkey[!is.na(year_from)]),
            .groups = "drop") %>%
  mutate(too_few = Observartions < min_obs,
         CRRA = ifelse(too_few, NA_real_, CRRA)) %>%
  rename(name = country) %>%
  mutate(name = ifelse(name %in% names(to_polygon),
                       unname(to_polygon[name]), name))

## A country can hold hundreds of observations and still be invisible on a
## 1:110m world: Singapore has no polygon in it at all, and a city state that
## did would be a pixel. Those get a dot instead, on the same colour scale
## and with the same tooltip, so the data are never there without the
## country showing.
##
## A country lands among the dots either because the polygon set has nothing
## for it -- then the coordinates come from the table below -- or because its
## polygon is smaller than 15,000 km2, in which case the dot sits on the
## polygon itself. The threshold is below the smallest country now in the
## data (Slovenia, 19,000 km2), so it only ever picks up micro-states.
dot_latlon <- tibble::tribble(
  ~name,                  ~lat,     ~lon,
  "Singapore",           1.3521, 103.8198,
  "Hong Kong",          22.3193, 114.1694,
  "Macao",              22.1987, 113.5439,
  "Malta",              35.9375,  14.3754,
  "Luxembourg",         49.8153,   6.1296,
  "Bahrain",            26.0667,  50.5577,
  "Qatar",              25.2854,  51.5310,
  "Mauritius",         -20.3484,  57.5522,
  "Trinidad and Tobago", 10.6918, -61.2225,
  "Brunei Darussalam",   4.5353, 114.7277)

no_polygon <- setdiff(na.omit(countries$name), as.character(world_map$name))
missing_coords <- setdiff(no_polygon, dot_latlon$name)
if (length(missing_coords)) {
  warning("Map: no polygon and no coordinates for ",
          paste(missing_coords, collapse = ", "),
          " -- add them to dot_latlon in server.R or they stay off the map.")
}

new_tab = left_join(world_map, countries, by = "name")


## Three states, not two: a country with enough data, one held back for too
## few observations, and one with none at all.
new_tab$`Risk propensity` <- dplyr::case_when(
  !is.na(new_tab$CRRA)                  ~ sprintf("%.3f", new_tab$CRRA),
  isTRUE_vec(new_tab$too_few)           ~ "Insufficient data",
  TRUE                                  ~ "no data yet")
new_tab$Observations <- ifelse(is.na(new_tab$Observartions),
                               "—",
                               format(new_tab$Observartions, big.mark = " ",
                                      trim = TRUE, scientific = FALSE))

label_geom <- new_tab %>%
  filter(!is.na(CRRA)) %>%
  arrange(desc(Observartions))

largest_ring <- function(geom) {
  parts <- suppressWarnings(
    sf::st_cast(sf::st_sfc(geom, crs = sf::st_crs(label_geom)), "POLYGON"))
  parts[[which.max(as.numeric(sf::st_area(parts)))]]
}
label_xy <- suppressWarnings(sf::st_coordinates(sf::st_point_on_surface(
  sf::st_sfc(lapply(sf::st_geometry(label_geom), largest_ring),
             crs = sf::st_crs(label_geom)))))

label_pts <- data.frame(name = label_geom$name,
                        lon  = label_xy[, 1],
                        lat  = label_xy[, 2],
                        stringsAsFactors = FALSE)

## A country drawn as a dot gets its name from the dot layer, so it must not
## also get one here or the two sit on top of each other.
tiny_names <- world_map %>%
  mutate(area_km2 = as.numeric(sf::st_area(.)) / 1e6) %>%
  sf::st_drop_geometry() %>%
  filter(area_km2 < 15000) %>%
  pull(name) %>%
  as.character()
label_pts <- label_pts %>% filter(!name %in% tiny_names)

Mypal <- c('#4dcb00','#e2cb00','#ee9663','#ee4128')

## One tooltip builder for the polygons and the dots alike, so the two can
## never drift apart.
##
## It deliberately does NOT show the publication years or the number of
## papers: neither tells the reader anything about the country. When the
## data were gathered does -- a period lines up with droughts, crises,
## lockdowns and reforms, which is exactly what makes a country's level
## worth a second look. That line is left out entirely where no paper has a
## collection year yet. It used to add "(1 of 2 papers)" when only some
## papers were dated; that note was dropped at the user's request (26.10.2026),
## so n_dated and n_papers are no longer shown.
make_label <- function(name, rp, obs, collected, n_dated, n_papers) {
  coll <- ifelse(is.na(collected), "",
                 sprintf("<br/>Data collected: %s", collected))
  lapply(sprintf("<b>%s</b><br/>Risk propensity: %s<br/>Observations: %s%s",
                 name, rp, obs, coll),
         htmltools::HTML)
}

map_labels <- make_label(new_tab$name, new_tab$`Risk propensity`,
                         new_tab$Observations, new_tab$Collected,
                         new_tab$n_dated, new_tab$n_papers)

## The countries that get a dot: those with no polygon at all, plus the ones
## whose polygon is too small to find. Both carry the same tooltip as the
## polygons, so nothing about them reads differently.
poly_area <- world_map %>%
  mutate(area_km2 = as.numeric(sf::st_area(.)) / 1e6) %>%
  sf::st_drop_geometry() %>%
  select(name, area_km2)

dot_tab <- countries %>%
  filter(!is.na(CRRA)) %>%
  left_join(poly_area, by = "name") %>%
  filter(is.na(area_km2) | area_km2 < 15000) %>%
  left_join(dot_latlon, by = "name") %>%
  left_join(label_pts %>% rename(plat = lat, plon = lon), by = "name") %>%
  mutate(lat = ifelse(is.na(lat), plat, lat),
         lon = ifelse(is.na(lon), plon, lon)) %>%
  filter(!is.na(lat) & !is.na(lon))

if (nrow(dot_tab)) {
  dot_tab$`Risk propensity` <- sprintf("%.3f", dot_tab$CRRA)
  dot_tab$Observations <- format(dot_tab$Observartions, big.mark = " ",
                                 trim = TRUE, scientific = FALSE)
  dot_labels <- make_label(dot_tab$name, dot_tab$`Risk propensity`,
                           dot_tab$Observations, dot_tab$Collected,
                           dot_tab$n_dated, dot_tab$n_papers)
} else {
  dot_labels <- list()
}

map_top  <- max(1.2, ceiling(max(new_tab$CRRA, na.rm = TRUE) * 10) / 10)
map_bins <- c(-0.3, 0, 0.2, 0.4, 0.6, 0.8, 1, map_top)
map_pal  <- colorBin(
  palette  = colorRampPalette(Mypal)(length(map_bins) - 1),
  domain   = new_tab$CRRA,
  bins     = map_bins,

  na.color = "#E6E6E6")

map_widget <-
leaflet(new_tab,
        options = leafletOptions(worldCopyJump = FALSE,
                                 minZoom = 2, maxZoom = 7,
                                 zoomSnap = 0.25, zoomDelta = 0.5,
                                 maxBoundsViscosity = 1.0)) %>%
  addPolygons(
    fillColor   = ~map_pal(CRRA),

    fillOpacity = 1,
    color       = "#9A9A9A",
    weight      = 0.5,
    opacity     = 1,
    label        = map_labels,
    labelOptions = labelOptions(direction = "auto", sticky = TRUE,
                                textsize = "13px", opacity = 0.97,
                                style = list(
                                  "padding"       = "8px 11px",
                                  "line-height"   = "1.45",
                                  "border"        = "1px solid rgba(0,0,0,.15)",
                                  "border-radius" = "4px",
                                  "box-shadow"    = "0 2px 8px rgba(0,0,0,.18)")),

    popup = map_labels
  ) %>%
  addLabelOnlyMarkers(
    lng = label_pts$lon, lat = label_pts$lat,
    label = label_pts$name,
    labelOptions = labelOptions(noHide = TRUE, direction = "center",
                                textOnly = TRUE,
                                className = "metaret-country-label")) %>%

  ## the micro-states, drawn on top of the polygons so the dot is not
  ## swallowed by the country it sits in
  addCircleMarkers(
    data = dot_tab,
    lng = ~lon, lat = ~lat,
    radius      = 6,
    fillColor   = ~map_pal(CRRA),
    fillOpacity = 1,
    color       = "#3C3C3C",
    weight      = 1.2,
    opacity     = 1,
    label        = dot_labels,
    labelOptions = labelOptions(direction = "auto", sticky = TRUE,
                                textsize = "13px", opacity = 0.97,
                                style = list(
                                  "padding"       = "8px 11px",
                                  "line-height"   = "1.45",
                                  "border"        = "1px solid rgba(0,0,0,.15)",
                                  "border-radius" = "4px",
                                  "box-shadow"    = "0 2px 8px rgba(0,0,0,.18)")),
    popup = dot_labels) %>%
  addLabelOnlyMarkers(
    data = dot_tab,
    lng = ~lon, lat = ~lat,
    label = ~name,
    labelOptions = labelOptions(noHide = TRUE, direction = "right",
                                offset = c(8, 0), textOnly = TRUE,
                                className = "metaret-country-label")) %>%
  addLegend(position = "bottomright",
            pal      = map_pal,
            values   = ~CRRA,
            title    = "Risk propensity",
            na.label = "No data yet",
            opacity  = 0.85) %>%

  ## empty margin around the world, wider on the right and at the bottom where
  ## the legend sits: with the bounds at the map edge New Zealand stayed
  ## under the legend and could not be panned out from behind it
  setMaxBounds(lng1 = -200, lat1 = -85, lng2 = 250, lat2 = 80) %>%
  fitBounds(lng1 = -172, lat1 = -55, lng2 = 178, lat2 = 72)

## Server function 
  server <- function(input, output, session){
    
    corr_avail_w <- function(id) {
      w <- session$clientData[[paste0("output_", id, "_width")]]
      if (is.null(w) || !is.finite(w) || w < 200) 900 else w
    }


    corr_avail_h <- function() {
      h <- input$metaret_viewport_h
      if (is.null(h) || !is.finite(h) || h < 400) h <- 850
      max(360, h - CORR_CHROME_H)
    }

    ## Home page 
    output$contributors <- renderValueBox({ 
      value_box(
        "Contributed papers"
        ,n_distinct(df$paper)
        ,color = "green")  
    })
    
    output$lotteries_num <- renderValueBox({ 
      value_box(
        'Tasks',
        df %>% filter(task != 'quest_only') %>%
          select(task) %>%
          n_distinct()
        ,color = "red")  
    })
    
    output$participants_num <- renderValueBox({
      value_box(
        'Participants',
        n_distinct(df$subject)
        ,color = "violet")
    })

    output$countries_num <- renderValueBox({
      value_box(
        'Countries',
        n_distinct(df$country[!is.na(df$country) & df$country != ""])
        ,color = "orange")
    })

    output$quest_num_home <- renderValueBox({
      qcols <- c("soep", "soep_patience", "soep_impulsive", "soep_financial",
                 "dosocial", "dohealth", "doinvest", "dogamble", "doethic",
                 "dorecre", "doall", "BIS", "BSSS", "AuditS", "CDCrisk")
      have <- qcols[vapply(qcols, function(cc) any(!is.na(df[[cc]])), logical(1))]
      instruments <- unique(ifelse(grepl("^soep", have), "SOEP",
                            ifelse(grepl("^do", have), "DOSPERT", have)))
      value_box(
        'Questionnaires',
        length(instruments)
        ,color = "blue")
    })
    
    ## Tasks page 
      ## First tab Tasks page 
    
    output$contributors_lot <- renderValueBox({ 
      value_box(
        "Contributed papers"
        ,n_distinct(filter(df, task == input$Tasks) %>% select(paper))
        ,color = "purple")  
    })
    
    output$participants_num_lot <- renderValueBox({ 
      value_box(
        'Participants',
        n_distinct(filter(df, task == input$Tasks) %>% select(subject))
        ,color = "purple")  
    })
    
    output$num_obs<- renderValueBox({ 
      value_box(
        "Observations"
        ,filter(df, task == input$Tasks) %>% select(subject) %>% nrow()
        ,color = "purple")  
    })
    
    output$lotteries <- renderPlot({
      data <- df %>%filter(task == input$Tasks)
      plotDensity(input$Tasks, data)
    })
    
    output$info_markdown <- renderInfoBox({
      df = desc_tasks %>% filter(tasks == input$Tasks) %>% pull(desc) 
      includeMarkdown(df)
    })

    output$table_papers_name <- renderDataTable({
      table = filter(df, task == input$Tasks) %>% 
        group_by(paper, author, title, year, journal, doi_2, url) %>% 
        summarise(sample=n(), .groups = "drop")
      table$link <- ""
      for (i in 1:nrow(table)){
        table$link[i] <- createLink(table$doi_2[i], table$url[i])
      }
      table = table %>% select(-paper, -doi_2, -url)
      return(table)}, escape = FALSE)
    
      ## Second tab Tasks page 
    
    observe({
      if(input$selectalltaskdist == 0) return(NULL) 
      else if (input$selectalltaskdist%%2 == 0)
      {
        updateCheckboxGroupInput(session,"id_selectInput",choices=mychoices, selected = mychoices)
      }
      else
      {
        updateCheckboxGroupInput(session,"id_selectInput",choices=mychoices, selected=list())
      }
    })
    
    observe({
      updateCheckboxGroupInput(session, "id_selectInput", NULL,choices=mychoices)
    })
    
    output$lotteries_comp <- renderPlot({
      ## a checkbox group: several tasks at once, so %in% (== recycled the
      ## selection against the rows and kept an arbitrary subset)
      data <- df %>% filter(task %in% input$id_selectInput)
      plotDensity1(input$id_selectInput, data)
    }, height = 700)
    
    
    ## Third tab tasks page 
    
    observe({
      if(input$selectalltaskcorrs == 0) return(NULL) 
      else if (input$selectalltaskcorrs%%2 == 0)
      {
        updateCheckboxGroupInput(session,"amongcorrs",choices=mychoices, selected = mychoices)
      }
      else
      {
        updateCheckboxGroupInput(session,"amongcorrs",choices=mychoices, selected=list())
      }
    })
    
    observe({
      updateCheckboxGroupInput(session, "amongcorrs", NULL,choices=mychoices)
    })

    m_corr_tasks <- reactive({
      corr_cache$cor_tasks[input$amongcorrs, input$amongcorrs, drop = FALSE]
    })

    output$corr_tasks <- renderPlot({
      corr_matrix_panel(m_corr_tasks(), symmetric = TRUE)
    },
    width  = function() corr_panel_width(m_corr_tasks(), corr_avail_w("corr_tasks"), corr_avail_h()),
    height = function() corr_panel_height(m_corr_tasks(), corr_avail_w("corr_tasks"), corr_avail_h()))
    
    
    ## Fourth tab tasks page 
    output$everytask <- renderPlot({
      data <- df %>% filter(task == input$selectedtask) %>% 
        filter(r > -1.5 & r < 2.5) 
      task_variability_plot(input$selectedtask, data)
    }, height = 820)
    
    ## Questionnaires page
      ## First tab questionnaires page
    output$task_num <- renderValueBox({ 
      value_box(
        "Tasks"
        , n_distinct(df %>% select(subject, task, starts_with('soep'), starts_with('do'),
                                   'BIS', 'BSSS', 'AuditS', 'CDCrisk') %>% 
                       select(-doi_2) %>%
                       pivot_longer(-c(subject, task), values_to = 'values', names_to = 'name') %>%
                       filter(name == input$Questionnaires) %>% drop_na() %>% select(task))
        ,color = "green")  
    })
    output$paper_num <- renderValueBox({ 
      value_box(
        "Contributed papers"
        , n_distinct(df %>% select(subject, bibkey, starts_with('soep'), starts_with('do'),
                                   'BIS', 'BSSS', 'AuditS', 'CDCrisk') %>% 
                       select(-doi_2) %>%
                       pivot_longer(-c(subject, bibkey), values_to = 'values', names_to = 'name') %>%
                       filter(name == input$Questionnaires) %>% drop_na() %>% select(bibkey))
        ,color = "green")  
    })
    
    output$quest_num <- renderValueBox({ 
      value_box(
        "Participants"
        , count(df %>% select(subject, starts_with('soep'),
                                   starts_with('do'),
                                   'BIS', 'BSSS', 'AuditS', 'CDCrisk') %>% 
                       select(-doi_2) %>% distinct() %>% select(input$Questionnaires) %>% drop_na()
                       )
        ,color = "green")  
    })

    output$questionnaires <- renderPlot({
      data <- df %>% select(subject, starts_with('soep'), 
                            starts_with('do'),'BIS', 'BSSS', 'AuditS', 'CDCrisk') %>% 
        select(-doi_2) %>%
        pivot_longer(-subject, values_to = 'values', names_to = 'name') %>%
        filter(name == input$Questionnaires) %>% drop_na()
      plotDensity2(input$Questionnaires, data)
    })
    
    output$info_markdown_quest <- renderInfoBox({
      df = desc_quest %>% filter(quest == input$Questionnaires) %>% pull(desc) 
      includeMarkdown(df)
    })
    
    output$table_papers_name_quest <- renderDataTable({
      table = df %>% filter(!is.na(.data[[input$Questionnaires]])) %>%
        select(subject, paper, author, title, year, journal, doi_2, url) %>%
        distinct() %>%
      group_by(paper, author, title, year, journal, doi_2, url) %>% 
      summarise(sample=n(), .groups = "drop")
      table$link <- ""
      for (i in 1:nrow(table)){
        table$link[i] <- createLink(table$doi_2[i], table$url[i])
      }
      table = table %>% select(-paper, -doi_2, -url)
      return(table)}, escape = FALSE)
    
    ## Second tab questionnaires page
    
    observe({
      if(input$selectallcorrquest == 0) return(NULL) 
      else if (input$selectallcorrquest%%2 == 0)
      {
        updateCheckboxGroupInput(session,"amongquest",choices=questionchoice, selected = questionchoice)
      }
      else
      {
        updateCheckboxGroupInput(session,"amongquest",choices=questionchoice, selected=list())
      }
    })
    
    observe({
      updateCheckboxGroupInput(session, "amongquest", NULL,choices=questionchoice)
    })
    
    
    m_corr_quest <- reactive({
      corr_cache$cor_quest[input$amongquest, input$amongquest, drop = FALSE]
    })

    output$corr_quest <- renderPlot({
      corr_matrix_panel(m_corr_quest(), symmetric = TRUE)
    },
    width  = function() corr_panel_width(m_corr_quest(), corr_avail_w("corr_quest"), corr_avail_h()),
    height = function() corr_panel_height(m_corr_quest(), corr_avail_w("corr_quest"), corr_avail_h()))
    
    ## Tasks and questionnaire page
    
    observe({
      if(input$selectalltasks == 0) return(NULL) 
      else if (input$selectalltasks%%2 == 0)
      {
        updateCheckboxGroupInput(session,"amongcorrs_1",choices=mychoices, selected = mychoices)
      }
      else
      {
        updateCheckboxGroupInput(session,"amongcorrs_1",choices=mychoices, selected=list())
      }
    })
    
      observe({
        if(input$selectallquest == 0) return(NULL) 
        else if (input$selectallquest%%2 == 0)
        {
          updateCheckboxGroupInput(session,"amongquest_1",choices=questionchoice_cor, selected = questionchoice_cor)
        }
        else
        {
          updateCheckboxGroupInput(session,"amongquest_1",choices=questionchoice_cor, selected=list())
        }
      })

    
    ## rectangular, so there is no diagonal to drop
    m_corr_quest_task <- reactive({
      corr_cache$cor_task_quest[input$amongquest_1,
                                input$amongcorrs_1, drop = FALSE]
    })

    output$corr_quest_task <- renderPlot({
      corr_matrix_panel(m_corr_quest_task())
    },
    width  = function() corr_panel_width(m_corr_quest_task(), corr_avail_w("corr_quest_task"), corr_avail_h()),
    height = function() corr_panel_height(m_corr_quest_task(), corr_avail_w("corr_quest_task"), corr_avail_h()))



    dl_corr_png <- function(m, symmetric = FALSE) {
      function(file) {
        grDevices::png(file, width = 12, height = 8, units = "in", res = 300, bg = "white")
        on.exit(grDevices::dev.off(), add = TRUE)
        corr_matrix_panel(m, symmetric = symmetric)
      }
    }

    output$dl_corr_tasks <- downloadHandler(
      filename = function() paste0("correlations-tasks-", Sys.Date(), ".png"),
      content = function(file) {
        sel <- input$amongcorrs
        dl_corr_png(corr_cache$cor_tasks[sel, sel, drop = FALSE],
                    symmetric = TRUE)(file)
      }
    )

    output$dl_corr_quest <- downloadHandler(
      filename = function() paste0("correlations-questionnaires-", Sys.Date(), ".png"),
      content = function(file) {
        sel <- input$amongquest
        dl_corr_png(corr_cache$cor_quest[sel, sel, drop = FALSE],
                    symmetric = TRUE)(file)
      }
    )

    output$dl_corr_quest_task <- downloadHandler(
      filename = function() paste0("correlations-tasks-questionnaires-", Sys.Date(), ".png"),
      content = function(file) {
        dl_corr_png(corr_cache$cor_task_quest[input$amongquest_1,
                                              input$amongcorrs_1, drop = FALSE])(file)
      }
    )
    ## these buttons sit on semantic.dashboard tabs hidden at start-up, so,
    ## as for download_dump below, they must not be suspended or they never
    ## receive a link and stay greyed out
    for (id in c("dl_corr_tasks", "dl_corr_quest", "dl_corr_quest_task"))
      outputOptions(output, id, suspendWhenHidden = FALSE)

    ## Demography page
    
    ## Gender task tab
    
    output$quant_gend_contr<- renderValueBox({ 
      value_box(
        "Contributed papers"
        ,if (input$genderdist == 'all'){
          n_distinct(df %>% 
                      filter(r > -1.5 & r < 2.5) %>%
                      select(gender,paper) %>% 
                      drop_na() %>% select(paper)) }
        else {n_distinct(filter(df, task == input$genderdist) %>% 
                            filter(r > -1.5 & r < 2.5) %>%
                            select(gender,paper) %>% 
                            drop_na() %>% select(paper))
          } ,color = "blue") 
    })
    
    output$quant_femmes <- renderValueBox({ 
      value_box(
        "Women"
        ,if (input$genderdist == 'all'){
          count(filter(df, gender == '1'))}
        else {
          count(filter(df, task == input$genderdist, gender == '1'))
        }
        ,color = "blue")  
    })
    
    output$quant_hommes <- renderValueBox({ 
      value_box(
        "Men"
        ,if (input$genderdist == 'all'){
          count(filter(df, gender == '0'))}
        else {
          count(filter(df, task == input$genderdist, gender == '0'))
        }
        ,color = "blue")  
    })
    
    output$gender_dist <- renderPlot({
      if (input$genderdist == 'all'){
      data = df %>% 
        filter(r > -1.5 & r < 2.5)}
      else {
        data = df %>% 
          filter(r > -1.5 & r < 2.5) %>% filter(task == input$genderdist)
      }
      plotgender(input$genderdist, data)
    })
    
    observe({
      updateCheckboxGroupInput(session, "genderdist", NULL,choices=mychoicesgender)
    })
    
    ## Gender questions tab
    
    output$quant_gend_contr_q<- renderValueBox({ 
      value_box(
        "Contributed papers"
        ,n_distinct(df %>% select(input$genderdist_quest, gender, paper) %>% 
                           drop_na() %>% select(paper))
        ,color = "blue") 
    })
    
  
    ## one row per person: a subject who did several tasks has the same
    ## questionnaire answer on every task row, and counting rows counted them
    ## several times (e.g. 4 times in Hackethal2023)
    quest_people <- function(q) {
      df %>% filter(!is.na(.data[[q]])) %>% distinct(bibkey, subject, .keep_all = TRUE)
    }

    output$quant_femmes_q <- renderValueBox({
      value_box(
        "Women"
        ,
          count(filter(quest_people(input$genderdist_quest), gender == '1'))
        ,color =  "blue")
    })

    output$quant_hommes_q <- renderValueBox({
      value_box(
        "Men"
        ,count(filter(quest_people(input$genderdist_quest), gender == '0'))
        ,color = "blue")
    })

    output$gender_dist_quest <- renderPlot({
        data = quest_people(input$genderdist_quest) %>%
          select(gender, input$genderdist_quest) %>% drop_na()
      plotgender_quest(input$genderdist_quest, data)
    })
    
    observe({
      updateCheckboxGroupInput(session, "genderdist_quest", NULL,choices=questionchoice_gender)
    })
    
    
    ## Age tab
    output$quant_contr_a <- renderValueBox({ 
      value_box(
        "Contributed papers"
    
        ,if (input$agedist == 'all'){
          n_distinct(df %>% 
            filter(r > -1.5 & r < 2.5, age >= 5) %>%
            select(paper, age) %>% 
            drop_na() %>% select(paper))} 
        else {
          n_distinct(df %>% 
            filter(r > -1.5 & r < 2.5, age >= 5) %>%
            filter(task == input$agedist) %>% 
              select(paper, age) %>% 
              drop_na() %>% select(paper))
        }
        ,color = "blue")  
    })
    
    output$quant_femmes_a <- renderValueBox({ 
      value_box(
        "Average age of women"
        ,if (input$agedist == 'all'){
         df %>% 
            filter(r > -1.5 & r < 2.5) %>%
            filter(gender == '1') %>% 
            select(age) %>% 
            drop_na() %>%  summarise(mean = round(mean(age))) %>% pull(mean)} 
        else {
          df %>% 
            filter(r > -1.5 & r < 2.5) %>%
            filter(gender == '1', task == input$agedist) %>% 
            select(age) %>% 
            drop_na() %>%  summarise(mean = round(mean(age))) %>% pull(mean)
        }
        ,color = "blue")  
    })
    
    output$quant_hommes_a <- renderValueBox({ 
      value_box(
        "Average age of men"
        ,if (input$agedist == 'all'){
          df %>% 
            filter(r > -1.5 & r < 2.5) %>%
            filter(gender == '0') %>% 
            select(age) %>% 
            drop_na() %>%  summarise(mean = round(mean(age))) %>% pull(mean)} 
        else {
          df %>% 
            filter(r > -1.5 & r < 2.5) %>%
            filter(gender == '0', task == input$agedist) %>% 
            select(age) %>% 
            drop_na() %>%  summarise(mean = round(mean(age))) %>% pull(mean)
        }
        ,color = "blue")  
    })
    
    
    
    ## the rows of the task age panel, within the picked age range; the plot
    ## and the slope line under it both read them
    age_task_rows <- reactive({
      req(input$agedist, input$agedist_range)
      data <- df %>% filter(r > -1.5 & r < 2.5)
      if (input$agedist != 'all') data <- data %>% filter(task == input$agedist)
      age_rows(data, "r", input$agedist_range)
    })
    output$age_dist <- renderPlot({
      plotage(input$agedist, age_task_rows())
    })
    output$age_dist_note <- renderUI({
      age_note(age_task_rows(), "r", "r", "r")
    })

    observe({
      updateCheckboxGroupInput(session, "agedist", NULL,choices=mychoicesgender)
    })
    
    ## Age questions tab
    
    output$quant_contr_aq <- renderValueBox({ 
      value_box(
        "Contributed papers"
        , n_distinct(df %>% 
                       select(input$agedist_q, paper, age) %>% 
                       drop_na() %>% select(paper))
        ,color = "blue")  
    })
    
    output$quant_femmes_aq <- renderValueBox({ 
      value_box(
        "Average age of women"
        ,quest_people(input$agedist_q) %>%
            filter(gender == '1') %>%
            select(age, input$agedist_q) %>%
            drop_na() %>%  summarise(mean = round(mean(age))) %>% pull(mean)
        ,color = "blue")
    })

    output$quant_hommes_aq <- renderValueBox({
      value_box(
        "Average age of men",
          quest_people(input$agedist_q) %>%
            filter(gender == '0') %>%
            select(age, input$agedist_q) %>% 
            drop_na() %>%  summarise(mean = round(mean(age))) %>% pull(mean)
        ,color = "blue")  
    })
    
    age_quest_rows <- reactive({
      req(input$agedist_q, input$agedist_q_range)
      age_rows(quest_people(input$agedist_q), input$agedist_q, input$agedist_q_range)
    })
    output$age_dist_quest <- renderPlot({
      plotage1(input$agedist_q, age_quest_rows())
    })
    output$age_dist_quest_note <- renderUI({
      age_note(age_quest_rows(), input$agedist_q, "the answer", "answer")
    })
    
    observe({
      updateCheckboxGroupInput(session, "agedist_q", NULL,choices=questionchoice_agetab)
    })
    
    ## Download page
    ##
    ## One file with everything, one row per subject and task exactly as in
    ## df_mod.csv: a subject who did two tasks has two rows (their questionnaire
    ## answers repeat), and a subject with questionnaires only has task "none".
    ## Paper and sample details are joined on, so the file can be used without
    ## the site. The columns are described in info_download.md.
    output$page_dump <- DT::renderDataTable(
      dump_view,
      rownames = FALSE, class = "compact nowrap",
      options = list(scrollX = TRUE, pageLength = 10))

    output$download_dump <- downloadHandler(
      filename = function() paste0("METARET_data_", Sys.Date(), ".csv"),
      content = function(file) readr::write_csv(dump, file, na = "")
    )
    ## The page is a semantic.dashboard tab, hidden when the session starts, and
    ## Shiny is not told when it is shown: a suspended download link then never
    ## gets its href and the button stays greyed out. The link costs nothing
    ## until clicked, so it is kept live.
    outputOptions(output, "download_dump", suspendWhenHidden = FALSE)

    output$map_crra <- renderLeaflet(map_widget)
    
}
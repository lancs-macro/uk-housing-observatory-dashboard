library(dplyr)

# HPU ---------------------------------------------------------------------

hpu_index <-
  readxl::read_excel("data-raw/hpu.xlsx") %>% 
  mutate(year_quarter = paste(Year, Quarter)) %>% 
  mutate(year_quarter = lubridate::yq(year_quarter)) %>% 
  select(Date = year_quarter, HPU)

# EPU ---------------------------------------------------------------------

epu_index <-
  readxl::read_xlsx("data-raw/epu.xlsx") %>%
  slice(-n()) %>% 
  mutate(year_month = paste(year, month)) %>%
  mutate(year_month = lubridate::ymd(year_month, truncated = 1)) %>%
  select(Date = year_month, EPU = UK_EPU_Index) %>%
  group_by(Date = zoo::as.Date(zoo::as.yearqtr(Date, "%b-%Y"))) %>%
  summarise_all(mean) %>% 
  drop_na()

# Highchart ---------------------------------------------------------------

library(highcharter)

highchart <-
  highchart(type = "stock") %>%
  hc_add_series(epu_index, hcaes(x = Date, y = EPU), zoomType = "x", visible = FALSE,
                type = "line", name = "Economic Policy Uncertainty", color = "#222d32")  %>%
  hc_add_series(hpu_index, hcaes(x = Date, y = HPU), zoomType = "x",
                type = "line", name = "House Price Uncertainty", color = "#B22222",
                alpha = 0.2) %>%
  hc_legend(
    align = 'top',
    verticalAlign = 'middle',
    enabled = TRUE, 
    layout = 'vertical',
    y = -200,
    x = 100,
    itemStyle = list(fontSize = "16px")
    ) %>% 
  hc_title(
    text = " House Price Uncertainty Index",
    style = list(`font-weight` = "600", `font-size` = "22px", useHTML = TRUE)) %>% 
  # hc_subtitle(text = "Deaths from bronchitis, emphysema and asthma") %>% 
  hc_xAxis(type = 'date',
           minRange = 10,
           breaks = list(breakSize = 10),
           labels = list(format = '{value:%Y}')) %>%
  hc_tooltip(valueDecimals = 0) %>%
  hc_rangeSelector(
    buttons = list(
      # list(type = 'month', count = 3, text = '3m'),
      # list(type = 'month', count = 6, text = '6m'),
      list(type = 'year', count = 1, text = '1y'),
      list(type = 'year', count = 5, text = '5y'),
      list(type = 'year', count = 10, text = '10y'),
      list(type = 'year', count = 20, text = '20y'),
      list(type = 'all', text = 'All')
    ),
    selected = 5) %>%  #, inputEnabled = FALSE
  hc_annotations(
    list(
      labels =
        list(
          list(
            point = list(x = datetime_to_timestamp(as.Date("1990/07/01")), 
                         y = 180, xAxis = 0, yAxis = 0),
            text = "'Boom & Bust' Economic Cycle"
          ),
          list(
            point = list(x = datetime_to_timestamp(as.Date("2008/07/01")), 
                         y = 280, xAxis = 0, yAxis = 0),
            text = "Financial Crisis"
          ),
          list(
            point = list(x = datetime_to_timestamp(as.Date("2016/06/01")), 
                         y = 270, xAxis = 0, yAxis = 0),
            text = "EU Referendum"
          ),
          list(
            point = list(x = datetime_to_timestamp(as.Date("2018/02/01")), 
                         y = 170, xAxis = 0, yAxis = 0),
            text = "Brexit Uncertainty"
          )
        )
    )
  )

# highchart

    
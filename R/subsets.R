#' This script loads the subsets that will help power the dashboard

subset_data <- function(data) {
  
  data <- data %>% 
    group_by(request_source) %>% 
    mutate(request_source_total = n()) %>%
    ungroup()
  
  data <- data %>% 
    mutate(created_date_static = lubridate::as_date(created_date),
           created_date_week = lubridate::week(created_date),
           created_date_month = lubridate::month(created_date, 
                                                 label = T, abbr = F))
  data <- data %>% 
    group_by(request_source, created_date_static) %>%
    mutate(request_by_day = n()) %>%
    ungroup() %>%
    group_by(request_source, created_date_week) %>%
    mutate(request_by_week = n()) %>%
    ungroup() %>%
    group_by(request_source, created_date_month) %>%
    mutate(request_by_month = n()) %>%
    ungroup()
  
  data <- data %>%
    mutate(day = wday(created_date, label = TRUE),
           hour = hour(created_date)) 
  
  return(data)
}
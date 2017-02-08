#' This script loads the csv files and ensures the correct data types are used
#' and that the column names align before binding the rows

# column names with proper spacing
col_names_311 <- c(
  "srn_number", "created_date", "updated_date", "action_taken",
  "owner", "request_type", "status", "request_source",
  "mobile_os", "anonymous", "assign_to", "service_date",
  "closed_date", "address_verified", "approximate_address",
  "address", "house_number", "direction", "street_name",
  "suffix", "zipcode", "latitude", "longitude", "location",
  "thompson_brothers_map_page", "thompson_brothers_map_column",
  "thompson_brothers_map_row", "area_planning_commissions",
  "council_district", "city_council_member",
  "neighborhood_council_code", "neighborhood_council_name",
  "police_precinct"
)

validate_columns <- function(df1, df2) {
  get_colnames <- tibble(
    df1 = colnames(df1), 
    df2 = colnames(df2)
  )
  
  check_match <- mutate(
    get_colnames,
    check_match = if_else(df1 == df2, "Match", NA_character_)) %>%
    summarise(errors = sum(is.na(check_match)))
  
  if_else(check_match$errors == 0, return(0), return(1))
}

load_data <- function() {
  data_2016 <- read_csv(
    "data/MyLA311_Service_Request_Data_2016.csv",
    skip = 1,
    col_names = col_names_311,
    col_types = read_rds("data/my311_spec.rds"),
    progress = FALSE
  )
  stop_for_problems(data_2016)

  data_2017 <- read_csv(
    "data/MyLA311_Service_Request_Data_2017.csv",
    skip = 1,
    col_names = col_names_311,
    col_types = read_rds("data/my311_spec.rds"),
    progress = FALSE
  )
  stop_for_problems(data_2017)
  
  if_else(validate_columns(data_2016, data_2017) == 0,
          return(bind_rows(data_2016, data_2017)),
          stop("Rows may not align: There was a non 0 exit from the `validate_columns` function")
  ) 
}
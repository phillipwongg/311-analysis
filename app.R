library(shiny)
library(shinydashboard)
library(RSocrata)
library(tidyverse)
library(plotly)

# READ From Socrata
# data_2016 <- read.socrata("https://data.lacity.org/A-Well-Run-City/MyLA311-Service-Request-Data-2016/ndkd-k878")
# data_2017 <- read.socrata("https://data.lacity.org/A-Well-Run-City/MyLA311-Service-Request-Data-2017/cfmg-7vj2")

# Read from Local
# data_2016 <- read_csv('./data/MyLA311_Service_Request_Data_2016.csv')
# data_2017 <- read_csv('./data/MyLA311_Service_Request_Data_2017.csv')

# full_dataset <- merge(data_2016, data_2017, all=TRUE)

header <- dashboardHeader(title = "LA 311 Dashboard")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Widgets", icon = icon("th"), tabName = "widgets")
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "Totals Chart",
            fluidRow(
              box(width=4,
                    dateRangeInput("dates", label = "Date Range",
                                     start="2016-01-01",
                                     end="2016-12-31")
                  )
              box(width=8,
                  
                  )
            )
            
    ),
    
    tabItem(tabName = "widgets",
            h2("Widgets tab content")
    )
  )
)

ui <- dashboardPage(header, sidebar, body)

server <- function(input, output) { }

shinyApp(ui, server)
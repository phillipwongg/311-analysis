library(shiny)
library(shinydashboard)
library(RSocrata)

data_2016 <- read.socrata("https://data.lacity.org/A-Well-Run-City/MyLA311-Service-Request-Data-2016/ndkd-k878")
data_2017 <- read.socrata("https://data.lacity.org/A-Well-Run-City/MyLA311-Service-Request-Data-2017/cfmg-7vj2")

full_dataset <- merge(data_2016, data_2017, all=TRUE)

header <- dashboardHeader()
sidebar <- dashboardSidebar()
body = dashboardBody()

ui <- dashboardPage(header, sidebar, body)

server <- function(input, output) { }

shinyApp(ui, server)
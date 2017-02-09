library(shiny)
library(shinydashboard)
#library(shinyjs)
library(tidyverse)
library(plotly)

source("R/load_data.R")
source("R/subsets.R")
source("R/value_counts.R")

# JS function ------------------------------------------------------------------ 
#scroll <- "
#shinyjs.scroll = function() { 
#$('body').animate({ scrollTop: 0 }, 'slow'); } "

# Colors ----------------------------------------------------------------------- 
pal <- RColorBrewer::brewer.pal(11, "Spectral")
qual5 <- c(pal[1], pal[3], pal[4], pal[9], pal[10])
qual6 <- c(pal[1], pal[3], pal[4], pal[8], pal[9], pal[10])
qual7 <- c(pal[1], pal[3], pal[4], pal[7], pal[8], pal[9], pal[10])
cool <- c(pal[7], pal[8], pal[9], pal[10], pal[11])
warm <- c(pal[5], pal[4], pal[3], pal[2], pal[1])
cool_gradient <- data_frame(
  range = c(0.000, 0.115, 0.290, 0.750, 1.000),
  hex = cool
)
warm_gradient <- data_frame(
  range = c(0.000, 0.115, 0.290, 0.750, 1.000),
  hex = warm
)

# Read data -------------------------------------------------------------------- 
data <- load_data()
data <- subset_data(data)

# ui --------------------------------------------------------------------------- 
header <- dashboardHeader(
  title = tags$a(href = "",
                 tags$img(src = "seal_of_los_angeles.png", height = "45", width = "40",
                          style = "display: block; padding-top: 5px;"))
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Requests", tabName = "dashboard", icon = icon("cloud-download")),
    menuItem("Map", tabName = "map", icon = icon("map-o")),
    menuItem("Service Items", tabName = "requests", icon = icon("truck"))
  )
)

body <- dashboardBody(
  useShinyjs(),
  #extendShinyjs(text = scroll),
  tags$body(id = "body"),
  includeCSS("www/custom.css"),
  tabItems(
    
    # Requests ----------------------------------------------------------------- 
    tabItem(
      tabName = "dashboard",
      fluidRow(
        box(
          title = "Time Series of Requests by Source", width = 12,
          plotlyOutput("requests_by_source")        
        ),
        box(
          title = "Heatmap of Request Traffic by Day and Time", width = 12,
          selectInput("request_source_heat", label = NULL, 
                      selected = "Mobile App", width = "12em",
                      choices = c(
                        "Call", "Driver Self Report",
                        "Mobile App", "Self Service",
                        "Email"
                      )),
          plotlyOutput("day_time_heatmap")
        )
      ) 
    ),
    
    tabItem(
      tabName = "map",
      h2("Map")
    ),
    tabItem(
      tabname = "requests",
      h2("Service Requests")
    )
  ) # end tabItems
) # body

ui <- dashboardPage(header, sidebar, body)

# server ----------------------------------------------------------------------- 
server <- function(input, output) { 
  
  output$requests_by_source <- renderPlotly({
    requests <- data %>%
      filter(request_source %in% c(
        "Call", "Driver Self Report",
        "Mobile App", "Self Service",
        "Email"
      )) %>%
      select(created_date_static, request_source,
             request_by_month, request_by_week) %>%
      arrange(created_date_static) %>%
      dplyr::distinct()
    
      p <- plot_ly(requests, x = ~created_date_static, 
              color = ~request_source, colors = "Set1") %>%
      add_trace(y = ~request_by_week, type = "scatter",
                mode = "lines", visible = TRUE) %>%
      add_trace(y = ~request_by_month, type = "scatter",
                mode = "lines", visible = FALSE) 
      
      p %>% layout(
        xaxis = list(
          title = "\nDate request was created",
          rangeslider = list(type = "date")
        ),
        yaxis = list(
          title = "Number of requests\n"
        ),
        legend = list(x = 1, y = 0.9),
        updatemenus = list(
          list(
            x = 0.1, y = 1.2,
            buttons = list(
              list(method = "restyle",
                   args = list("visible", append(
                     rep(list(TRUE), 5),
                     rep(list(FALSE), 5)
                   )),
                   label = "Weekly"),
              list(method = "restyle",
                   args = list("visible", append(
                     rep(list(FALSE), 5),
                     rep(list(TRUE), 5)
                   )),
                   label = "Monthly")
            )
          )
        ))
    
  })
  
  output$day_time_heatmap <- renderPlotly({
    heat <- data %>%
      filter(request_source == input$request_source_heat) %>%
      group_by(day, hour) %>%
      count()
    
    p <- heat %>%
      plot_ly() %>%
      add_heatmap(x = ~day, y = ~hour, z = ~n,
                  colorscale = warm_gradient, showscale = F,
                  text = ~paste("Day: ", day, "<br>Hour: ", hour,
                                "<br>Total Requests: ", n),
                  hoverinfo = "text") 
    
    p %>% layout(xaxis = list(title = ""),
                 yaxis = list(title = "Hour of the day"))
  })
  
}

# run app ---------------------------------------------------------------------- 
shinyApp(ui, server)
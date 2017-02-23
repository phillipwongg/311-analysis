library(shiny)
library(shinydashboard)
#library(shinyjs)
library(tidyverse)
library(plotly)
library(leaflet)

source("R/load_data.R")
source("R/subsets.R")
source("R/load_shapefile.R")
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
districts <- load_shapefile(data)

# ui --------------------------------------------------------------------------- 
header <- dashboardHeader(
  title = tags$a(href = "",
                 tags$img(src = "seal_of_los_angeles.png", height = "45", width = "40",
                          style = "display: block; padding-top: 5px;"))
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Requests", tabName = "requests", icon = icon("cloud-download")),
    menuItem("Maps", tabName = "maps", icon = icon("map-o")),
    menuItem("Services", tabName = "services", icon = icon("truck"))
  )
)

body <- dashboardBody(
  #useShinyjs(),
  #extendShinyjs(text = scroll),
  tags$body(id = "body"),
  includeCSS("www/custom.css"),
  tabItems(
    # Requests ----------------------------------------------------------------- 
    tabItem(
      tabName = "requests",
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
    # Maps ---------------------------------------------------------------------- 
    tabItem(
      tabName = "maps",
      tags$style(type = "text/css", "#district_map {height: calc(100vh - 80px)!important;}"),
      leafletOutput("district_map"),
      absolutePanel(
        top = 80, right = 30,
        selectInput(
          "map_request_type", label = NULL,
          selected = "total_requests", choices = c(
            "Total Requests" = "total_requests",
            "Bulky Items" = "bulky_items", 
            "Dead Animal Removal" = "dead_animal_removal", 
            "Electronic Waste" = "electronic_waste", "Feedback"  = "feedback",
            "Graffiti Removal" = "graffiti_removal",
            "Homeless Encampment" = "homeless_encampment",
            "Illegal Dumping Pickup" = "illegal_dumping_pickup",
            "Metal Household Appliances" = "metal_household_appliances",
            "Multiple Streetlight Issue" = "multiple_streetlight_issue",
            "Other" = "other", "Report Water Waste"  = "report_water_waste",
            "Single Streetlight Issue" = "single_streetlight_issue"
          )
        )
      )
    ),
    # Services ----------------------------------------------------------------- 
    tabItem(
      tabName = "services",
      box(
        input <- dateRangeInput('dateRange',
                                label = 'Date Range',
                                start = Sys.Date() - 365, end = Sys.Date()-2),
        width = 12
      ),
      box(
        title="Service Request Types by Day", 
        width = 12,
        plotlyOutput("request_type_hist")
      )
    )
  ) # end tabItems
) # body

ui <- dashboardPage(header, sidebar, body)

# server ----------------------------------------------------------------------- 
server <- function(input, output) { 
  
  # requests ------------------------------------------------------------------- 
  output$requests_by_source <- renderPlotly({
    requests <- data %>%
      filter(request_source %in% c(
        "Call", "Driver Self Reprenort",
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
  
  output$request_type_hist <- renderPlotly({
    title_string <- paste("Request Types by Volume from ", as.character(input$dateRange[1]), " to ", as.character(input$dateRange[2]) )
    plot_ly(data %>% subset(data$created_date > input$dateRange[1] & data$created_date < input$dateRange[2]),
            x = ~request_type, type="histogram", colors = "Set1") %>% 
          
           layout(title = title_string , 
                xlab("Request Type")
             )
             
    
  })
  
  # maps ----------------------------------------------------------------------- 
  
  # reactive data
  districts_map <- reactive({
    districts@data <- districts@data %>% 
      select_("name", "DISTRICT", input$map_request_type) 
    
    colnames(districts@data) <- c("name", "district", "totals")
    
    districts
  })
  
  output$district_map <- renderLeaflet({
    
    mapbox <- "https://api.mapbox.com/styles/v1/robertmitchellv/cipr7teic001aekm72dnempan/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoicm9iZXJ0bWl0Y2hlbGx2IiwiYSI6ImNpcHI2cXFnbTA3MHRmbG5jNWJzMzJtaDQifQ.vtvgLokcc_EJgnWVPL4vXw"
    
    popup <- paste(
      "<strong>District:</strong>", 
      districts_map()@data$district, 
      "<br><strong>", 
      stringr::str_replace_all(stringr::str_to_title(input$map_request_type), "_", " "), 
      ":</strong>", districts_map()@data$totals,
      sep = " "
    )
    
    leaflet() %>%
      addTiles(mapbox) %>%
      setView(lng = -118.2427, lat = 34.0537, zoom = 10) %>%
      addPolygons(
        data = districts_map(), popup = popup,
        stroke = T, weight = 0.5, fillOpacity = 0.5, smoothFactor = 0.5,
        color = ~colorNumeric(warm, districts_map()$totals)(totals)
      )
  })
  
}

# run app ---------------------------------------------------------------------- 
shinyApp(ui, server)

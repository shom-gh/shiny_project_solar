
library(shiny)
library(shinydashboard)



dashboardPage(
  dashboardHeader(title = "My Dashboard"),
  dashboardSidebar(
    sidebarUserPanel("Ilyas",
                     image = 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Macaca_nigra_self-portrait_large.jpg'),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem('Equipment', tabName = 'equipment', icon = icon('map')),
      menuItem("Energy", tabName = "daily", icon = icon("map"))
    ),
    
    sliderInput("month", 
                label = h3("Select Month"), 
                min = 1, 
                max = 12, 
                value = 6),

    selectInput('state', 
                label = h3('Select State'),
                choices = list(state.abb = state.abb), 
                selected = 'AL')
  ),
  
  dashboardBody(
    tabItems(
    tabItem(
      tabName = "map",
      fluidRow(
        box( h4('Mothly Insolation Map', align = 'center'),
          htmlOutput("map"),
                   width = 8
            ),
        box(htmlOutput('statemonth'),
                   width = 4)
               
        ),
      
      fluidRow(box(htmlOutput("hist"),
                   width = 8)
               )
    ),
    tabItem(
      tabName = 'equipment',
      fluidRow(
        box(
          h4('My panel specs:'),
          numericInput("panel_area", label = h4("Panel surface area (in sq.m)"), 
                       value = 2),
          numericInput("panel_efficiency", label = h4("Panel efficiency (%)"), 
                       value = 16.9),
          numericInput("panel_price", label = h4("Panel price (USD)"), 
                       value = 300),
          width = 3
        ),
        box(
          h4('My battery specs:'),
          numericInput("battery_cap", label = h4("Battery capacity (kWh)"), 
                       value = 13.5),
          numericInput("battery_price", label = h4("Battery price (USD)"), 
                       value = 6000),
          width = 3
        ),
        box(
          h4('My inverter specs:'),
          numericInput("inv_maxi", label = h4("Inverter max current (A)"), 
                       value = 25),
          numericInput("inv_maxv", label = h4("Inverter max voltage (V)"), 
                       value = 600),
          numericInput("inv_price", label = h4("Inverter price (USD)"), 
                       value = 2000),
          width = 3
        ),
        box(
          h4('My MPPT converter specs:'),
          numericInput("mppt_voltage", label = h4("Converter  max voltage (V)"), 
                       value = 48),
          numericInput("mppt_amps", label = h4("Converter max current (A)"), 
                       value = 100),
          numericInput("mppt_price", label = h4("Converter price (USD)"), 
                       value = 100),
          width = 3
        )
      )
    ),
    tabItem(
      tabName = "daily",
      fluidRow(
        box(htmlOutput("daily"),
            width = 9),
        box(htmlOutput('balance'),
            width = 3
            )
        ),
      fluidRow(
        box(sliderInput('capacity',
                        label = h4('Choose battery capacity'),
                        min = 1,
                        max = 10,
                        value = 1),
            width = 3,
            height = 100),
        box(sliderInput('area',
                    label = h4('Total area for solar panels (m^2)'),
                    min = 1,
                    max = 200,
                    value = 50),
            width = 3,
            height = 100),
        box(
          dateInput("date", label = h4("Date input"), value = "2017-01-01"),
          width = 3
        ),
        box(
          numericInput("consumption", label = h4("My monthly electrical bill is"), 
                       value = 100),
          width = 3,
          height = 100
        )
            )
)
)
)
)
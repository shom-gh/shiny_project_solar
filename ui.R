
library(shiny)
library(shinydashboard)



dashboardPage( skin = 'black',
  dashboardHeader(title = "My Dashboard"),
  dashboardSidebar(
    sidebarUserPanel(h5('Solar system calculator'),
                     h5('by Ilyas Shomayev')
                     ),
    sidebarMenu(
      menuItem("Intro", tabName = "intro", icon = icon("book")),
      menuItem("Map", tabName = "map", icon = icon("sun-o")),
      menuItem('Equipment', tabName = 'equipment', icon = icon('gears')),
      menuItem("Energy", tabName = "daily", icon = icon("battery-2")),
      menuItem("Price", tabName = "price", icon = icon("dollar"))
    ),
    


    selectInput('state', 
                label = h3('Select State'),
                choices = list(state.abb = state.abb), 
                selected = 'AL')
  ),
  
  dashboardBody(
    # tags$head(tags$style(HTML('
    #     .skin-black .main-header .logo {
    #                           background: #666; 
    #                           color:black;
    #                           }
    #                           .skin-black .main-header .logo:hover {
    #                           background: rgb(150,150,150);
    #                           }
    #                           .skin-black .left-side, .skin-black .main-sidebar, .skin-black .wrapper{
    #                           background: #666 
    #                           }
    #                           .skin-black .main-header .navbar{
    #                           background: #666; 
    #                           }
    #                           .skin-black .sidebar a{
    #                           font-family: monospace
    #                           }
    #                           .skin-black .body a{
    #                           font-family: monospace
    #                           }
    #                           '))),
    tabItems(
    tabItem(
      tabName = 'intro',
      fluidRow(
        box(img(src = 'pv_price.svg', width = 500),
            width = 6),
        box(img(src= 'electricity.png', width = 500),
            width = 6)
      )
    ),
    tabItem(
      tabName = "map",
      fluidRow(
        box( h4('Mothly Insolation Map', align = 'center'),
          htmlOutput("map"),
                   width = 8
            ),
        box(
          h4('Monthly Solar Irradiance', align = 'center'),
          htmlOutput('statemonth'),
          width = 4)
               
        ),
      
      fluidRow(
        box(
          h4('State Insolation Histogram'),
          htmlOutput("hist"),
          width = 8),
        box(
          sliderInput("month", 
                      label = h3("Select Month"), 
                      min = 1, 
                      max = 12, 
                      value = 6),
          width = 4
        )
        )
    ),
    tabItem(
      tabName = 'equipment',
      h2('Select Your Equipment. NO LOITERING!'),
      fluidRow(
        box(
          h4('My panel specs:'),
          numericInput("panel_area", label = h4("Panel surface area (in sq.m)"), 
                       value = 2),
          numericInput("panel_voltage", label = h4("Max panel voltage (V)"), 
                       value = 45.9),
          numericInput("panel_amps", label = h4("Max panel current (A)"), 
                       value = 9.3),
          numericInput("panel_efficiency", label = h4("Panel efficiency (%)"), 
                       value = 16.9),
          numericInput("panel_price", label = h4("Panel price (USD)"), 
                       value = 200),
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
                       value = 50),
          numericInput("inv_maxv", label = h4("Inverter max voltage (V)"), 
                       value = 600),
          numericInput("inv_price", label = h4("Inverter price (USD)"), 
                       value = 1000),
          width = 3
        ),
        box(
          h4('My MPPT converter specs:'),
          numericInput("mppt_voltage", label = h4("Converter  max voltage (V)"), 
                       value = 48),
          numericInput("mppt_amps", label = h4("Converter max current (A)"), 
                       value = 100),
          numericInput("mppt_price", label = h4("Converter price (USD)"), 
                       value = 300),
          width = 3
        ),
        box(
          h4('Total System Losses:'),
          numericInput('system_losses', label = h4('Default is set to 0.85'),
                       value = 0.85)
        )
      )
    ),
    tabItem(
      tabName = "daily",
      h2('System Stability and Performance', align = 'center'),
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
            height = 120),
        box(sliderInput('area',
                    label = h4('Total area for solar panels (m^2)'),
                    min = 1,
                    max = 200,
                    value = 50),
            width = 3,
            height = 120),
        box(
          dateInput("date", label = h4("Date input"), value = "2017-01-01"),
          width = 3,
          height = 120
        ),
        box(
          numericInput("consumption", label = h4("My monthly electrical bill is (USD)"), 
                       value = 100),
          width = 3,
          height = 120
          )
        )
      ),
    tabItem(
      tabName = 'price',
      h2("Price estimations"),
      fluidRow(
        infoBoxOutput('panel_price', width = 3),
        infoBoxOutput('inv_price', width = 3)
        ),
      fluidRow(
        infoBoxOutput('bat_price', width = 3),
        infoBoxOutput('mppt_price', width = 3)
        ),
      fluidRow(
        infoBoxOutput('total_price')
        ),
      fluidRow(
        infoBoxOutput('roi')
        )
    )
    )
    )
  )
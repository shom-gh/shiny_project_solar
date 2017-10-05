
library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "My Dashboard"),
  dashboardSidebar(
    sidebarUserPanel("Ilyas",
                     image = 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Macaca_nigra_self-portrait_large.jpg'),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
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
                selected = 'AL'),
    sliderInput('area',
                label = h3('Select Availiable Area (m^2)'),
                min = 1,
                max = 200,
                value = 50)
    
  ),
  
  dashboardBody(
    tabItems(
    tabItem(
      tabName = "map",
      fluidRow(box(htmlOutput("map"),
                   title = h2('Mothly Insolation Map'))
               ),
      fluidRow(box(htmlOutput("hist")))
    ),
    tabItem(
      tabName = "daily",
      fluidRow(
        box(infoBoxOutput("daily"))
      )
    )
  )
)
)
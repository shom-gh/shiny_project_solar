library(shiny)
library(DT)
library(dplyr)
library(data.table)
library(googleVis)

efficiency = 0.16
multiplier = 1000/(30*24)

solar_data = fread('solar_data.csv')
#consumption = fread('consumpiton.csv')

function(input, output){
  
  
  
  solar_map <- reactive({
    solar_data %>% ungroup() %>% group_by(State, month) %>% 
      summarise(monthly_irradiance = mean(avg_ghi)) %>%
      filter(month == as.numeric(input$month)) %>% arrange(monthly_irradiance)
  })
  
  state_data <- reactive({
    solar_data %>% ungroup() %>%filter(State == input$state  & month == input$month) %>%
      group_by(time) %>% summarise(hourly_ghi = mean(avg_ghi)) %>%
      mutate(panel_perf = efficiency*hourly_ghi*input$area) %>%
      mutate(cons = multiplier*consumption[consumption$abb == input$state, 3])
  }) 
  
 output$map <- renderGvis({
   gvisGeoChart(solar_map(), "State", 'monthly_irradiance',
                options=list(region="US", displayMode="regions",
                             resolution="provinces",
                             colorAxis="{colors:['grey', 'orange']}",
                             backgroundColor="lightblue",
                             title = 'Average Monthly Irradiance Map',
                             width="auto", height="auto"))
 })

 
 output$hist <- renderGvis(
   gvisHistogram(solar_map()[,'monthly_irradiance',
                           drop=FALSE],
                 options = list(colors="['orange']")))


 output$daily <- renderGvis(
   gvisColumnChart(state_data(), xvar = 'time' , yvar = c( 'panel_perf', 'cons'),
                options = list(width = 500, height = 500,
                               title = 'Hourly Energy Chart',
                               legend="bottom",
                               bar="{groupWidth:'100%'}"))
                 
 )

 
 
}



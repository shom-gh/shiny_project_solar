library(shiny)
library(DT)
library(dplyr)
library(data.table)
library(googleVis)

efficiency = 0.16
multiplier = 1000/(30*24)

solar_data = fread('solar_data.csv')
#solar_data = solar_data %>% mutate(date = as.Date(paste('2017', month, day, sep = '/')))

consumption = fread('consumption_v2.csv')


function(input, output){


  
  solar_map <- reactive({
    solar_data %>% ungroup() %>% group_by(State, month) %>% 
      summarise(monthly_irradiance = mean(avg_ghi)) %>%
      filter(month == as.numeric(input$month)) %>% arrange(monthly_irradiance)
  })
  
  test_data <- reactive({
    solar_data %>% mutate(panel_perf = efficiency*avg_ghi*input$area) %>% 
      mutate(cons = multiplier*as.numeric(consumption[consumption$abb == input$state, 4])) %>%
      filter(State == input$state & month == month(input$date) & day == mday(input$date))
      
  })
  
  state_data <- reactive({
      temp<-solar_data %>% ungroup() %>% filter(State == input$state & month == input$month) %>%
      group_by(time) %>% summarise(hourly_ghi = mean(avg_ghi)) %>%
      mutate(panel_perf = efficiency*hourly_ghi*input$area) %>%
      mutate(cons = multiplier*as.numeric(consumption[consumption$abb == input$state, 4])) %>% 
      ungroup() %>% mutate(total = sum(panel_perf))  %>%
      mutate(index = as.numeric(substr(time, 1,2))) %>% 
      mutate(charge = input$capacity*500)
      
      chargevec = c()
      for (i in 1:24){
        chargevec[i] = ifelse(i ==1, input$capacity*500,
                           ifelse(chargevec[i-1]>input$capacity*1000,
                                  input$capacity*1000,
                                  chargevec[i-1]) + temp$panel_perf[i] -
                             temp$cons[i])}

      temp$charge = chargevec
      
      temp  #%>% mutate(charge = ifelse(charge >input$capacity*1000, input$capacity*1000, charge))
      #mutate(battery = (input$capacity*500  + panel_perf  - index*cons)) %>%
       #mutate(battery = ifelse(battery >input$capacity*1000, input$capacity*1000, battery))
      
  }) 
  
  
  
 output$map <- renderGvis({
   gvisGeoChart(solar_map(), "State", 'monthly_irradiance',
                options=list(region="US", displayMode="regions",
                             resolution="provinces",
                             colorAxis="{colors:['grey', 'orange']}",
                             backgroundColor="#2f4f4f",
                             title = 'Average Monthly Irradiance Map',
                             width="auto", height="auto"))
 })

 
 output$hist <- renderGvis(
   gvisHistogram(solar_map()[,'monthly_irradiance',
                           drop=FALSE],
                 options = list(colors="['orange']",
                                backgroundColor="#2f4f4f")
                 )
   )


 output$daily <- renderGvis(
   gvisColumnChart(state_data(), xvar = 'time' , yvar = c( 'panel_perf', 'cons', 'charge'),
                   options = list(width = "100%", height = 400,
                                  vAxes="[{title:'MYTEXT'}]",
                                  title = 'Hourly Energy Chart',
                                  legend="bottom",
                                  bar="{groupWidth:'100%'}"))
                 
 )
 

   
 
}



library(shiny)
library(DT)
library(dplyr)
library(data.table)
library(googleVis)
library(dygraphs)


solar_data = fread('solar_data_v2.csv')
consumption = fread('consumption_v2.csv')


function(input, output){
  


  hourly_cons <- reactive ({ 1000/(30*24*0.85)*input$consumption/consumption[consumption$abb == input$state, 6]*
    consumption[consumption$abb == input$state, 4]
  })
  
  solar_map <- reactive({
    solar_data %>% ungroup() %>% group_by(State, month) %>% 
      summarise(monthly_irradiance = sum(avg_ghi)/30000) 
      # filter(month == as.numeric(input$month))
  })
  
   test_data <- reactive({
     temp2 <- solar_data %>% mutate(Production = input$panel_efficiency/100*avg_ghi*input$area) %>%
       mutate(Consumption = as.numeric(hourly_cons())) %>%
       #filter(State == input$state & month == month(input$date) & day == mday(input$date))
       filter(State == input$state)
     chargevec = c()
     runout = c()
     for (i in 1:nrow(temp2)) 
     {
       if (i ==1) {
         chargevec[i] = input$capacity*as.numeric(input$battery_cap*1000)/2
       } else if (chargevec[i-1]+temp2$Production[i] - temp2$Consumption[i] > input$capacity*as.numeric(input$battery_cap*1000)) {
         chargevec[i] = input$capacity*as.numeric(input$battery_cap*1000)
       } else {
         chargevec[i] = chargevec[i-1]+temp2$Production[i] - temp2$Consumption[i]
         if (chargevec[i] < 0) {
           chargevec[i] = 0
         }
       }
     }
     for (i in 1:nrow(temp2))
     {
       runout[i] = ifelse(chargevec[i] == 0, 1, 0)
     }
     temp2$Charge = chargevec
     temp2$runout = runout
     # temp2$runout = temp2[temp2$charge == 0, 7][[1]][1]
     temp2  #%>% filter(month == month(input$date) & day == mday(input$date)) 
   })
   

  # output$warning <- reactive ({
  #   max_series = as.integer(input$mppt_voltage/input$panel_voltage)
  #   max_strings = as.integer(input$mppt_amps/input$panel_amps)
  #   HTML(paste0('Configuration limits: \n', max_strings, ' strings, \n',
  #               max_series, 'panles in series'))
  # })
   
  output$panel_price <- renderInfoBox({
     infoBox(
       "Panels", 
       paste0(as.integer(input$area/input$panel_area), ' panels in total \n',
       as.integer(input$area/input$panel_area)*input$panel_price, '$'),
       icon = icon("dollar"),
       color = "blue"
     )
  })
  
  output$inv_price <-  renderInfoBox({
    infoBox(
      'Inverters',
      paste0('1', ' inverters in total \n',
      as.integer(input$inv_price), '$'),
      icon = icon("dollar"),
      color = "blue"
    )
  })
  
  output$bat_price <-  renderInfoBox({
    infoBox(
      'Batteries',
      paste0(input$capacity, ' batteries in total \n',
             input$battery_price*input$capacity, '$'),
      icon = icon("dollar"),
      color = "blue"
    )
  })
  
  output$mppt_price <-  renderInfoBox({
    infoBox(
      'mppt',
      paste0('1', ' converters in total \n',
             as.integer(input$mppt_price), '$'),
      icon = icon("dollar"),
      color = "blue"
    )
  })
  
  output$total_price <-  renderInfoBox({
    infoBox(
      'total',
      paste0('TOTAL PRICE \n',
             as.integer(input$area/input$panel_area)*input$panel_price +
               as.integer(input$inv_price) +
               input$battery_price*input$capacity +
               as.integer(input$mppt_price), '$'),
      icon = icon("cart-arrow-down"),
      color = "green"
    )
  })
  
  output$roi <-  renderInfoBox({
    infoBox(
      'roi',
      paste0(as.integer((as.integer(input$area/input$panel_area)*input$panel_price +
               as.integer(input$inv_price) +
               input$battery_price*input$capacity +
               as.integer(input$mppt_price))/(input$consumption)), ' months'),
      icon = icon("clock-o"),
      color = "yellow"
    )
  })  
   
 output$map <- renderGvis({ 
   gvisGeoChart(solar_map() %>% filter(month == input$month), "State", 'monthly_irradiance',
                options=list(region="US", displayMode="regions",
                             resolution="provinces",
                             colorAxis="{colors:['grey', 'orange']}",
                             titleTextStyle="{color:'white', fontName:'Roboto', fontSize:16}",
                             backgroundColor="#2f4f4f",
                             title = 'Average Monthly Irradiance Map',
                             width="auto", height="auto")
                )
 })

 
  output$hist <- renderGvis({      
   gvisHistogram(solar_map() %>% filter(month == input$month) %>% select(monthly_irradiance), 
                 options = list(colors="['orange']",
                                backgroundColor="#e3e3e3",
                                legend = '{position: "none"}',
                                titleTextStyle="{color:'white', fontName:'Roboto', fontSize:30}",
                                vAxis="{title:'States (counts)', tltleTextStyle:{fontName:'Roboto', fontSize:40}}",
                                yAxis="{title:'Cumulative Irradiance (kWh)'}")
                 )
   })

  output$statemonth <- renderGvis({
    gvisColumnChart(solar_map() %>% filter(State == input$state) %>% mutate(month = month.abb[month]), 
                    xvar = 'month' , yvar = 'monthly_irradiance',
                    options = list(width = "100%", height = 400,
                                   colors="['orange']",
                                   backgroundColor="#e3e3e3",
                                   vAxes="[{title:'Cumulative Irradiance (kWh)'}]",
                                   legend="none",
                                   bar="{groupWidth:'100%'}")
    )
  })
  
 
 output$daily <- renderGvis({
   gvisColumnChart(test_data() %>% filter(month == month(input$date) & day == mday(input$date)), 
                   xvar = 'time' , 
                   yvar = c( 'Production', 'Consumption', 'Charge'),
                   options = list(width = "100%", height = 500,
                                  vAxes="[{title:'Energy (Wh)'}]",
                                  title = 'Hourly Energy Estimations',
                                  titleTextStyle="{color:'black', 
                                                  fontSize:16}",
                                  legend="bottom",
                                  bar="{groupWidth:'100%'}")
                   )
   })
 output$balance <- renderGvis({
   gvisBarChart(test_data() %>% group_by(month) %>% summarise(Balance = as.integer((sum(Production) - sum(Consumption))/1000),
                                                              Empty_Hours = -1*sum(runout)) %>%
                  mutate(month = month.abb[month]),
                xvar = 'month',
                yvar = c('Balance', 'Empty_Hours'),
                options = list(height = 500,
                               title="Energy Surplus/Deficit",
                               titleTextStyle="{color:'black', 
                                              fontSize:16}",   
                               legend = 'bottom',
                               xAxes="[{title:'Energy Balance, kWh'}]")
                )
 })
}



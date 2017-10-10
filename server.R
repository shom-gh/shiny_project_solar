library(shiny)
library(DT)
library(dplyr)
library(data.table)
library(googleVis)
library(dygraphs)


solar_data = fread('solar_data_v2.csv')
consumption = fread('consumption_v2.csv')


function(input, output){
  


  hourly_cons <- reactive ({ 1000/(30*24)*input$consumption/consumption[consumption$abb == input$state, 6]*
    consumption[consumption$abb == input$state, 4]
  })
  
  solar_map <- reactive({
    solar_data %>% ungroup() %>% group_by(State, month) %>% 
      summarise(monthly_irradiance = sum(avg_ghi)/30000) 
      # filter(month == as.numeric(input$month))
  })
  
   test_data <- reactive({
     temp2 <- solar_data %>% mutate(panel_perf = input$panel_efficiency/100*avg_ghi*input$area) %>%
       mutate(cons = as.numeric(hourly_cons())) %>%
       #filter(State == input$state & month == month(input$date) & day == mday(input$date))
       filter(State == input$state)
     chargevec = c()
     emptycounter <<- 0
     for (i in 1:nrow(temp2)) 
     {
       if (i ==1) {
         chargevec[i] = input$capacity*as.numeric(input$battery_cap*1000)/2
       } else if (chargevec[i-1]+temp2$panel_perf[i] - temp2$cons[i] > input$capacity*as.numeric(input$battery_cap*1000)) {
         chargevec[i] = input$capacity*as.numeric(input$battery_cap*1000)
       } else {
         chargevec[i] = chargevec[i-1]+temp2$panel_perf[i] - temp2$cons[i]
         if (chargevec[i] < 0) {
           chargevec[i] = 0
           emptycounter <<-  emptycounter + 1
         }
       }
     }
     temp2$charge = chargevec
     # temp2$runout = temp2[temp2$charge == 0, 7][[1]][1]
     temp2  #%>% filter(month == month(input$date) & day == mday(input$date)) 
   })
   
  output$message1 <- renderPrint({
     emptycounter
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
                                vAxis="{title:'States (counts)', tltleTextStyle:{fontName:'Roboto', fontSize:40}}")
                 )
   })

  output$statemonth <- renderGvis({
    gvisColumnChart(solar_map() %>% filter(State == input$state), xvar = 'month' , yvar = 'monthly_irradiance',
                    options = list(width = "100%", height = 400,
                                   vAxes="[{title:'Energy (Watts)'}]",
                                   title = 'Hourly Energy Chart',
                                   legend="bottom",
                                   bar="{groupWidth:'100%'}")
    )
  })
  
 
 output$daily <- renderGvis({
   gvisColumnChart(test_data() %>% filter(month == month(input$date) & day == mday(input$date)), 
                   xvar = 'time' , 
                   yvar = c( 'panel_perf', 'cons', 'charge'),
                   options = list(width = "100%", height = 500,
                                  vAxes="[{title:'Energy (Wh)'}]",
                                  title = 'Hourly Energy Chart',
                                  legend="bottom",
                                  bar="{groupWidth:'100%'}")
                   )
   })
 output$balance <- renderGvis({
   gvisBarChart(test_data() %>% group_by(month) %>% summarise(balance = as.integer((sum(panel_perf) - sum(cons))/1000)) %>%
                  mutate(month = month.abb[month]),
                xvar = 'month',
                yvar = 'balance',
                options = list(height = 500,
                               title="Energy Surplus/Deficit",
                               titleTextStyle="{color:'black', 
                                              fontSize:16}",   
                               legend = 'none',
                               xAxes="[{title:'Energy Balance, kWh'}]")
                )
 })
}



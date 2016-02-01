library(shiny)
library(devtools)
library(data.table)
library(markdown)
library(ggplot2)
library(plyr)
library(gridExtra)

# Load data
SolarData <- read.csv("NEM_CurrentlyInterconnectedDataset_2015-10-31 - Brief and Narrow.csv",header = TRUE)

SolarData$System.Size.DC       <- as.numeric(SolarData$System.Size.DC)
SolarData$Service.County       <- as.factor(SolarData$Service.County)
SolarData$App.Complete.Date    <- as.Date(SolarData$App.Complete.Date,"%m/%d/%Y")
SolarData$App.Received.Date    <- as.Date(SolarData$App.Received.Date,"%m/%d/%Y")
SolarData$App.Days.To.Complete <- as.numeric(difftime(SolarData$App.Complete.Date,SolarData$App.Received.Date, units = c("days")))
SolarData$App.Complete.YYYYQQ <- paste(format(SolarData$App.Complete.Date, "%y-"), 0, 
                                       sub( "Q", "", quarters(SolarData$App.Complete.Date) ), sep = "")
SolarData <- subset(SolarData, SolarData$App.Complete.YYYYQQ <= "15-04")

Counties       <- levels(SolarData$Service.County)
CustomerSector <- c("All", "Residential", "Commercial")

shinyServer(function(input,output,session){
   
     
      # County Check Box
      output$CountyControls <- renderUI({
            selectInput('Counties', 'Counties', Counties, selected = "Alameda")
      })
      
      # Sector
      output$SectorControls <- renderUI({
            selectInput('CustomerSector', 'Customer Sector', CustomerSector, selected = "All")
        
      })
      
      
      Subset_County_DC_Date <- reactive({
            if (input$CustomerSector == "All") {
                  County_Projects_DC_Date <- subset(SolarData,SolarData$Service.County == input$Counties )
                  County_Projects_Sum_DC <- data.frame(aggregate(County_Projects_DC_Date$System.Size.DC ,by=list(County_Projects_DC_Date$App.Complete.YYYYQQ,County_Projects_DC_Date$Service.County), FUN=sum, na.rm = TRUE))
                  colnames(County_Projects_Sum_DC) <- c('Date','County', "DC")
                  County_Projects_Sum_DC$Date = as.factor(County_Projects_Sum_DC$Date)
                  County_Projects_Sum_DC <- County_Projects_Sum_DC
            }      
            
            else {
                  County_Projects_DC_Date <- subset(SolarData,SolarData$Service.County == input$Counties & SolarData$Customer.Sector == input$CustomerSector )
                  County_Projects_Sum_DC <- data.frame(aggregate(County_Projects_DC_Date$System.Size.DC ,by=list(County_Projects_DC_Date$App.Complete.YYYYQQ,County_Projects_DC_Date$Service.County), FUN=sum, na.rm = TRUE))
                  colnames(County_Projects_Sum_DC) <- c('Date','County', "DC")
                  County_Projects_Sum_DC$Date = as.factor(County_Projects_Sum_DC$Date)
                  County_Projects_Sum_DC <- County_Projects_Sum_DC
            } 
      })    
    
      Subset_County_Projects_Date <- reactive({
            if (input$CustomerSector == "All") {
                  County_Projects_Date_Subset <- subset(SolarData,SolarData$Service.County == input$Counties )
                  County_Projects_Date <- data.frame(aggregate(County_Projects_Date_Subset$Counter,by=list(County_Projects_Date_Subset$App.Complete.YYYYQQ,County_Projects_Date_Subset$Service.County), FUN=sum, na.rm = TRUE))
                  colnames( County_Projects_Date ) <- c('Date','County', "Projects")
                  County_Projects_Date$Date = as.factor(County_Projects_Date$Date)
                  County_Projects_Date <- County_Projects_Date
            }      
            
            else {
                  County_Projects_Date_Subset <- subset(SolarData,SolarData$Service.County == input$Counties & SolarData$Customer.Sector == input$CustomerSector)
                  County_Projects_Date <- data.frame(aggregate(County_Projects_Date_Subset$Counter,by=list(County_Projects_Date_Subset$App.Complete.YYYYQQ,County_Projects_Date_Subset$Service.County), FUN=sum, na.rm = TRUE))
                  colnames( County_Projects_Date ) <- c('Date','County', "Projects")
                  County_Projects_Date$Date = as.factor(County_Projects_Date$Date)
                  County_Projects_Date <- County_Projects_Date
            }    
      }) 
     
      County_Projects_Avg_Install <- reactive({
            if (input$CustomerSector == "All") {
                  County_Projects_Avg_Subset <- subset(SolarData,SolarData$Service.County == input$Counties )
                  County_Projects_Avg_Install <- data.frame(aggregate(County_Projects_Avg_Subset$App.Days.To.Complete ,by=list(County_Projects_Avg_Subset$App.Complete.YYYYQQ,County_Projects_Avg_Subset$Service.County), FUN=mean, na.rm = TRUE))
                  colnames(County_Projects_Avg_Install) <- c('Date','County', "InstallDays")
                  County_Projects_Avg_Install$Date = as.factor(County_Projects_Avg_Install$Date)
                  County_Projects_Avg_Install <- County_Projects_Avg_Install
            }      
                 
            else {
                  County_Projects_Avg_Subset <- subset(SolarData,SolarData$Service.County == input$Counties & SolarData$Customer.Sector == input$CustomerSector)
                  County_Projects_Avg_Install <- data.frame(aggregate(County_Projects_Avg_Subset$App.Days.To.Complete ,by=list(County_Projects_Avg_Subset$App.Complete.YYYYQQ,County_Projects_Avg_Subset$Service.County), FUN=mean, na.rm = TRUE))
                  colnames(County_Projects_Avg_Install) <- c('Date','County', "InstallDays") 
                  County_Projects_Avg_Install$Date = as.factor(County_Projects_Avg_Install$Date)
                  County_Projects_Avg_Install <- County_Projects_Avg_Install
            }
      })
     
      Subset_County_Installers_Project <- reactive({
            if (input$CustomerSector == "All") {
                  County_Projects_Installer_Subset <- subset(SolarData,SolarData$Service.County == input$Counties)
                  County_Projects_Installer_Count  <-  data.frame(aggregate(County_Projects_Installer_Subset$Counter ,by=list(County_Projects_Installer_Subset$Installer.Name), FUN=sum, na.rm = TRUE))
                  colnames(County_Projects_Installer_Count) <- c('Installer','Projects')
                  County_Projects_Installer_Count<- County_Projects_Installer_Count[order (County_Projects_Installer_Count$Projects,decreasing = TRUE), ]
            }
            else {
                  County_Projects_Installer_Subset <- subset(SolarData,SolarData$Service.County == input$Counties & SolarData$Customer.Sector == input$CustomerSector)
                  County_Projects_Installer_Count  <-  data.frame(aggregate(County_Projects_Installer_Subset$Counter ,by=list(County_Projects_Installer_Subset$Installer.Name), FUN=sum, na.rm = TRUE))
                  colnames(County_Projects_Installer_Count) <- c('Installer','Projects')
                  County_Projects_Installer_Count<- County_Projects_Installer_Count[order (County_Projects_Installer_Count$Projects,decreasing = TRUE), ]
            }
      })
   
      Subset_County_Installers_DC <- reactive({
            if (input$CustomerSector == "All") {
                  County_Projects_Installer_Subset <- subset(SolarData,SolarData$Service.County == input$Counties)
                  County_Projects_Installer_DC  <-  data.frame(aggregate(County_Projects_Installer_Subset$System.Size.DC ,by=list(County_Projects_Installer_Subset$Installer.Name), FUN=sum, na.rm = TRUE))
                  colnames(County_Projects_Installer_DC) <- c('Installer','KiloWatts.DC')
                  County_Projects_Installer_DC<- County_Projects_Installer_DC[order (County_Projects_Installer_DC$KiloWatts.DC,decreasing = TRUE), ]
            }
            else {
                  County_Projects_Installer_Subset <- subset(SolarData,SolarData$Service.County == input$Counties & SolarData$Customer.Sector == input$CustomerSector)
                  County_Projects_Installer_DC  <-  data.frame(aggregate(County_Projects_Installer_Subset$System.Size.DC ,by=list(County_Projects_Installer_Subset$Installer.Name), FUN=sum, na.rm = TRUE))
                  colnames(County_Projects_Installer_DC) <- c('Installer','KiloWatts.DC')
                  County_Projects_Installer_DC<- County_Projects_Installer_DC[order (County_Projects_Installer_DC$KiloWatts.DC,decreasing = TRUE), ]
            }
      })
      
      output$Date <- renderPlot({
            g<-ggplot(Subset_County_DC_Date(), aes(x=Date, y=DC/1000)) + geom_bar(stat="identity") + ggtitle(input$Counties) 
            g<- g + xlab("Year-Qtr") + ylab("MegaWatts-DC") + theme(axis.text.y = element_text(size=8))
            g<- g + theme(axis.text.x=element_text(angle = -90))
            print(g)
      }) 
     
      output$Projects <- renderPlot({
            g<-ggplot(Subset_County_Projects_Date(), aes(x=Date, y=Projects)) + geom_bar(stat="identity") + ggtitle(input$Counties) + xlab("Date") + ylab("Projects") + theme(axis.text.y = element_text(size=8)) + theme(axis.text.x=element_text(angle = -90))
            print(g)
      })  
      
      output$InstallAvg <- renderPlot({
            g<-ggplot(County_Projects_Avg_Install(), aes(x=Date, y=InstallDays)) + geom_bar(stat="identity") + ggtitle(input$Counties) + xlab("Date") + ylab("Install Days") + theme(axis.text.y = element_text(size=8)) + theme(axis.text.x=element_text(angle = -90))
            print(g)
      }) 
      
      output$Inst <- renderDataTable({
           Subset_County_Installers_Project()
      })
           
      output$InstDC <- renderDataTable({
            Subset_County_Installers_DC()      
           
      }) 
      
      
      })      

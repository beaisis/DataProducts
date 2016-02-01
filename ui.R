library(shiny)

shinyUI(
    
      
      navbarPage("Solar Installs", 
             
             tabPanel("View the Data",
                  sidebarPanel(
                      uiOutput("CountyControls"),
                      uiOutput("SectorControls"),
                      width = 3,
                      br(),
                      p(em("Note: Data may take a few seconds to load")),
                      br(),
                      p(strong("Tabs:")),
                     
                      p("Energy -> Energy (Megawatts) brought online by Quarter"),
                      br(),
                      p("Projects -> Number of projects by Quarter"),
                      br(),
                      p("Avg Time -> Average days from approval to completion"),
                      br(),
                      p("Installers-Energy -> Total Energy delivered by Installer (Descending)"),
                      br(),
                      p("Installers-Projects -> Number of Projects delivered by Installer (Descending)")
                   ),   # end Sidebar           
          
            
             mainPanel(
                   
                   tabsetPanel(
                         
                         tabPanel(p(icon("line-chart"), h5("Energy")),
                                  plotOutput('Date')
                         ),
                         
                         tabPanel(p(icon("line-chart"), h5("Projects")),
                                  plotOutput('Projects')
                         ),
                         
                         tabPanel(p(icon("line-chart"), h5("AVG Time")),
                                  plotOutput('InstallAvg')
                         ),
                         
                         tabPanel(p(icon("table"), h5("Installers-Energy")),
                                  dataTableOutput('Inst')
                         ),
                         tabPanel(p(icon("table"), h5("Installers-Projects")),
                                  dataTableOutput('InstDC')
                         )
                        
                         
                   )  # end tabset panel
             ) # end Mainpanel 
             ),  #End view
             tabPanel("About", 
                      mainPanel(
                            includeMarkdown("about.md")
                      )
             )  #end tabpanel 
           
        )  #End Navbar
) #End Shiny
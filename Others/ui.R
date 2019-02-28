library(shiny)
library(shinydashboard)
library(plotly)

shinyUI <- dashboardPage(
  dashboardHeader(title = "RhythmicAlly"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Input data",tabName = "input"),
      menuItem("Full Data Visualisation",tabName = "full_mon_vis"),
      menuItem("All as Actograms",tabName = "all_acto"),
      menuItem("All Periodograms",tabName = "all_per"),
      menuItem("Individual Data",tabName = "acto_period"),
      menuItem("Raw Ind Profiles",tabName = "raw_profile"),
      menuItem("Prop Ind Profiles",tabName = "prop_profile"),
      menuItem("Average Profiles",tabName = "average_profiles"),
      menuItem("Rose Plots",tabName = "rose_plots"),
      menuItem("CoM",tabName = "com_phase"),
      menuItem("Download Data",tabName = "download")
    )
  ),
  
  dashboardBody(
    fluidRow(
      tabItems(
        tabItem(tabName = "input",
                sidebarPanel(
                  # Input: Select a file ----
                  fileInput("file", "Choose DAM monitor File",
                            multiple = FALSE,
                            accept = c("text/csv",
                                       "text/comma-separated-values,text/plain",
                                       ".csv")),
                  # Horizontal line ----
                  tags$hr(),
                  # Input: Checkbox if file has header ----
                  checkboxInput("header", "Header", FALSE),
                  # Input: Select separator ----
                  radioButtons("sep", "Separator",
                               choices = c(Comma = ",",
                                           Semicolon = ";",
                                           Tab = "\t"),
                               selected = "\t"),
                  # Input: Select quotes ----
                  # radioButtons("quote", "Quote",
                  #              choices = c(None = "",
                  #                          "Double Quote" = '"',
                  #                          "Single Quote" = "'"),
                  #              selected = '"'),
                  # Horizontal line ----
                  tags$hr(),
                  # Input: Select number of rows to display ----
                  radioButtons("disp", "Display",
                               choices = c(Head = "head",
                                           All = "all"),
                               selected = "head"),
                  numericInput("bins","bins (min)",60,1,120,1),
                  numericInput("modulotau","desired modulo tau",24,16,32,1),
                  # numericInput("nplot","number of plots (in your actogram)",2,1,5,1),
                  textInput("name_your_plots","Caption")
                ),
                # Main panel for displaying outputs ----
                mainPanel(
                  # Output: Data file ----
                  box(
                    width=12,
                    div(style = 'overflow-x: scroll', tableOutput("contents")))
                )),
        
        tabItem(tabName = "full_mon_vis",
                fluidRow(
                  sidebarPanel(
                    sliderInput(
                      "max_z_full","highest z in your case (this would depend on how much acitvity there is/bin)",
                      1,250,10,1)
                  ),
                  box(plotlyOutput("full.monitor",height="500px"),
                      width = 12
                  )
                )
        ),
        
        tabItem(tabName = "all_acto",
                fluidRow(
                  # tabItems(
                    # tabItem(tabName = "input2",
                            sidebarPanel(
                              numericInput("nplot","number of plots (in your actogram)",2,1,5,1),
                              sliderInput(
                                "max_z","highest z in your case (this would depend on how much acitvity there is/bin)",
                                1,250,10,1)
                            ),
                            # Main panel for displaying outputs ----
                            mainPanel(
                              # Output: Data file ----
                              plotlyOutput("all.actograms",height="500px"),
                                  height = 8,
                                  width = 12
                              # )
                            )
                    # )
                  # )
                )
        ),
        
        tabItem(tabName = "all_per",
                fluidRow(
                  sidebarPanel(
                    numericInput("permethod",
                                 "method to be used in periodogram analysis (1 = chi-square, 2 = autocorrelation, 3 = lomb-scargle)",
                                 1,1,3,1),
                    sliderInput("lowest","shortest period in your periodogram analysis",
                                10,20,16,1),
                    sliderInput("highest","longest period in your periodogram analysis",
                                26,36,32,1),
                    numericInput("alpha",
                                 "alpha for significance tests in periodogram analysis",
                                 0.05,0,1)
                  ),
                  # Main panel for displaying outputs ----
                  mainPanel(
                    # Output: Data file ----
                    box(plotlyOutput("all.per",height="500px"),
                        width = 12
                    ),
                    # box(
                    #   tableOutput("dataTable.period"),
                    #               width=2),
                    # box(
                    #   tableOutput("dataTable.power"),
                    #               width=2)
                    box(
                      # tableOutput("dataTable.period_power"),
                      width=12,
                      div(style = 'overflow-x: scroll', tableOutput('dataTable.period_power')))
                  )
                  
        )),
        
        tabItem(tabName = "acto_period",
                fluidRow(
                  sidebarPanel(
                    numericInput("ind_actogram",
                                 "individual id",
                                 1,1,33,1
                    ),
                    numericInput("nplot_ind","nplots",2,1,5,1),
                    
                    sliderInput("threshold","threshold",
                                0,2,0.5,0.01
                    ),
                    numericInput("first_time","starting time",4,1,24,0.01),
                    width = 2
                  ),
                  
                  # Main panel for displaying outputs ----
                  # mainPanel(
                    # Output: Data file ----
                    box(
                      plotlyOutput("acto",height = "500px")
                      #   width = 6,
                      # height = "500px"
                    ),
                    box(
                      plotlyOutput("period"),
                        width = 4
                    ),
                  box(
                    # tableOutput("dataTable.time_index"),
                      width=12,
                      div(style = 'overflow-x: scroll', tableOutput('dataTable.time_index')))
                  # )
                )
        ),
        
        tabItem(tabName = "raw_profile",
                fluidRow(
                  
                  # Main panel for displaying outputs ----
                  # mainPanel(
                    # Output: Data file ----
                    box(
                    plotlyOutput("raw_prof",height="500px"),
                    width=12
                    ),
                  box(
                    # tableOutput("profiles"),
                    width=12,
                    div(style = 'overflow-x: scroll', tableOutput('raw_profiles')))
                  
                )
        ),
        
        tabItem(tabName = "prop_profile",
                fluidRow(
                  
                  # Main panel for displaying outputs ----
                  # mainPanel(
                  # Output: Data file ----
                  box(
                    plotlyOutput("prop_prof",height="500px"),
                    width=12
                  ),
                  box(
                    # tableOutput("profiles"),
                    width=12,
                    div(style = 'overflow-x: scroll', tableOutput('prop_profiles')))
                  
                )
        ),
        
        tabItem(tabName = "average_profiles",
                fluidRow(
                  
                  # Main panel for displaying outputs ----
                  # mainPanel(
                  # Output: Data file ----
                  box(title="Raw Profile",
                    plotlyOutput("mean_raw_prof",height = "300px"),
                    width=5
                  ),
                  box(title="Proportion Profile",
                    plotlyOutput("mean_prop_prof",height = "300px"),
                    width=5
                  )
                  # )
                )
        ),
        
        tabItem(tabName = "rose_plots",
                fluidRow(
                  sidebarPanel(
                    numericInput("ind_actogram_rose",
                                 "individual id",
                                 1,1,33,1
                    )
                    ),
                    
                  # Main panel for displaying outputs ----
                  # mainPanel(
                  # Output: Data file ----
                  box(
                    plotlyOutput("rose",height = "300px"),
                      width = 4
                    # height = "500px"
                  )
                  )
                #   box(
                #     plotlyOutput("period"),
                #     width = 4
                #   ),
                #   box(
                #     # tableOutput("dataTable.time_index"),
                #     width=12,
                #     div(style = 'overflow-x: scroll', tableOutput('dataTable.time_index')))
                #   # )
                # )
        ),
        
        tabItem(tabName = "com_phase",
                fluidRow(
                  # sidebarPanel(
                  #   numericInput("ind_actogram_rose",
                  #                "individual id",
                  #                1,1,33,1
                  #   )
                  # ),
                  
                  # Main panel for displaying outputs ----
                  # mainPanel(
                  # Output: Data file ----
                  box(
                    plotlyOutput("com",height = "300px"),
                    width = 4
                    # height = "500px"
                  ),
                  box(
                    # tableOutput("profiles"),
                    width=12,
                    div(style = 'overflow-x: scroll', tableOutput('com_phases')))
                  
                # )
                )
                #   box(
                #     plotlyOutput("period"),
                #     width = 4
                #   ),
                #   box(
                #     # tableOutput("dataTable.time_index"),
                #     width=12,
                #     div(style = 'overflow-x: scroll', tableOutput('dataTable.time_index')))
                #   # )
                # )
        ),
        
        tabItem(tabName = "download",
                fluidRow(
                  sidebarPanel(
                    selectInput("dataset","Choose a dataset to download:",
                                choices = c("raw average profiles","prop average profiles","phases from actogram figures","all period power","CoM")),
                    downloadButton("downloadData","Download data")
                    
                  ),
                  mainPanel(
                    # tableOutput("table")
                    box(
                      width=12,
                    div(style = 'overflow-x: scroll', tableOutput('table')))
                    
                  )
                )
        )
        
      )
    )
  )
)
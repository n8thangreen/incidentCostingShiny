library(shiny)
library(shinyBS)
library(shinyLP)
library(shinythemes)

# ui <-

shinyUI(
  fluidPage(

    navbarPage("Menu",

               tabPanel("Home", icon = icon("home"),
                        jumbotron("TB incident costing", "text to show", buttonLabel = "Click Me")),

               tabPanel("Tool",
                        titlePanel("TB incident costing"),

                        # Sidebar layout with input and output definitions ----
                        sidebarLayout(

                          # Sidebar panel for inputs ----
                          sidebarPanel(

                            # Input: Select a file ----
                            fileInput("file1", "Choose CSV File",
                                      multiple = TRUE,
                                      accept = c("text/csv",
                                                 "text/comma-separated-values, text/plain",
                                                 ".csv")),

                            # Horizontal line ----
                            tags$hr(),

                            numericInput(label = "Number of incidents",
                                         value = 1,
                                         inputId = "nincid"),

                            selectInput("site", "Site:",
                                        c("School" = "school",
                                          "Workplace" = "workplace",
                                          "Other" = "other")),

                            sliderInput(inputId = "pRAphone",
                                        label = "Proportion of Risk Assessment by phone:",
                                        min = 0, max = 1, value = 0.5),

                            sliderInput(inputId = "pScreenIMM",
                                        label = "Proportion screening events following an Incident Management Meeting:",
                                        min = 0, max = 1, value = 0.5),

                            sliderInput(inputId = "pScreensite",
                                        label = "Proportion site visit of screening events:",
                                        min = 0, max = 1, value = 0.5),

                            radioButtons(inputId = "testtype", label = "Type of test:",
                                         choices = c("IGRA" = "igra", "TST" = "tst")),

                            radioButtons(inputId = "location", label = "Location:",
                                         choices = c("London" = "london", "Birmingham" = "birmingham"))

                          ),

                          # Main panel for displaying outputs ----
                          mainPanel(

                            # Output: Tabset w/ plot, summary, and table ----
                            tabsetPanel(type = "tabs",
                                        tabPanel("Flow diagram",
                                                 img(src = 'flowdiagram.png', width = "1000", align = "left")),
                                        tabPanel("Plot",
                                                 downloadButton("save_plot", "Save Image"),
                                                 plotOutput("plot")),
                                        tabPanel("Summary", verbatimTextOutput("summary")),
                                        tabPanel("Table counts",
                                                 downloadButton("save_counts",
                                                                "Save Table"),
                                                 tableOutput("dat")),
                                        tabPanel("Table costs",
                                                 downloadButton("save_costs",
                                                                "Save Table"),
                                                 tableOutput("datcost")),
                                        tabPanel("Uploaded data", tableOutput("contents"))
                            )

                            # Output: Formatted text for caption ----
                            #h3(textOutput("caption")),

                            # Output: Plot of the requested variable against mpg ----
                            #plotOutput("mpgPlot")

                          ))
               )
    )
  )
)

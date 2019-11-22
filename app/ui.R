library(shiny)

ui <- fluidPage(

  titlePanel("TB incident costing"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      numericInput(label = "Number of incidents",
                   value = 1,
                   inputId = "nincid"),

      # Input: Selector for variable to plot against mpg ----
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


      # Input: Checkbox for whether outliers should be included ----
      # checkboxInput("outliers", "Show outliers", TRUE)

    ),

    # Main panel for displaying outputs ----
    mainPanel(

      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  tabPanel("Flow diagram", img(src = 'flowdiagram.png', width = "1000", align = "left")),
                  tabPanel("Plot", plotOutput("plot")),
                  tabPanel("Summary", verbatimTextOutput("summary")),
                  tabPanel("Table counts", tableOutput("dat")),
                  tabPanel("Table costs", tableOutput("datcost"))
      )

      # Output: Formatted text for caption ----
      #h3(textOutput("caption")),

      # Output: Plot of the requested variable against mpg ----
      #plotOutput("mpgPlot")

    )
  )
)

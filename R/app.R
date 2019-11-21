library(shiny)
# https://shiny.rstudio.com/articles/build.html


# Define UI for miles per gallon app ----
ui <- fluidPage(

  # App title ----
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
                  tabPanel("Table", tableOutput("table"))
      )

      # Output: Formatted text for caption ----
      #h3(textOutput("caption")),

      # Output: Plot of the requested variable against mpg ----
      #plotOutput("mpgPlot")

    )
  )
)



### this is the calculation on the raw data
### to present direct estimates

# library(reshape2)
# library(dplyr)
# library(rsample)
# library(purrr)
# library(tidyr)
# library(broom)
#
#
# source("functions.R")
# source("VBA_converted.R")
# source("model_data.R")
#
#
# ########
# # prep #
# ########
#
# # individual incidents counts by setting and year
# dat_raw <-
#   readxl::read_xlsx(
#     path = here::here("../data", "Birmingham", "incidents2.xlsx"),
#     sheet = "data")
#
# dat <- dat_raw[ ,
#                 c("year", "setting2", "Total No identified",
#                   "Total No Screened", "Latent")]
#
# names(dat)[names(dat) == "setting2"] <- "setting"
#
# # remove incidents with missing data
# dat <- dat[dat$year %in% 2013:2018, ]
# dat <- dat[!is.na(dat$`Total No identified`), ]
# dat <- dat[!is.na(dat$`Total No Screened`), ]
#
# dat$Latent[is.na(dat$Latent)] <- 0
#
# dat <-
#   dat %>%
#   mutate(setting = factor(setting),
#          p_screen = `Total No Screened`/`Total No identified`,          #prop screened of identified for each incident
#          p_ltbi = `Latent`/`Total No Screened`,
#          cost = vtotal_year_cost(inc_sample = 1,
#                                  id_per_inc = `Total No identified`,    #each incident cost
#                                  screen_per_inc = `Total No Screened`,
#                                  ltbi_per_inc = `Latent`),
#          dcost_per_id = cost/`Total No identified`,
#          dcost_per_screen = cost/`Total No Screened`,
#          dcost_per_ltbi = cost/Latent,
#          identified = `Total No identified`,
#          screen = `Total No Screened`,
#          latent = Latent,
#          incidents = 1)
#
#
# write.csv(dat, file = "data/raw_inc_data_cleaned.csv")
#
#
# ####################
# # direct summaries #
# ####################
# # these are useful also to
# # check against bootstrap estimates
#
# # annual total
# # total number of individuals within each year and setting
# total_year_setting <-
#   dat %>%
#   sum_by_group(year, setting)
#
# # # mean number of individuals within each setting
# # dat_means <-
# #   dat %>%
# #   mean_by_group(setting)
#
# dat_means <-
#   mean_by_setting(total_year_setting)
#
#
# # incident as unit level average
# dat %>%
#   group_by(setting) %>%
#   summarise(
#     identified = mean(`Total No identified`, na.rm = TRUE),
#     screen = mean(`Total No Screened`, na.rm = TRUE),
#     latent = mean(Latent, na.rm = TRUE),
#     cost = mean(cost, na.rm = TRUE),
#     cost_per_id = cost/identified,            #E(cost)/E(screen)
#     cost_per_screen = cost/screen,
#     cost_per_ltbi = cost/latent)








# Define server logic to plot various variables against mpg ----
mpgData <- mtcars
mpgData$am <- factor(mpgData$am, labels = c("Automatic", "Manual"))

dat <- incident_data
total_year_cost()

# Define server logic to plot various variables against mpg ----
server <- function(input, output) {

  # Compute the formula text ----
  # This is in a reactive expression since it is shared by the
  # output$caption and output$mpgPlot functions
  formulaText <- reactive({
    paste("mpg ~", input$variable)
  })

  # Return the formula text for printing as a caption ----
  output$caption <- renderText({
    formulaText()
  })

  # Generate a plot of the requested variable against mpg ----
  # and only exclude outliers if requested
  output$mpgPlot <- renderPlot({
    boxplot(as.formula(formulaText()),
            data = mpgData,
            outline = input$outliers,
            col = "#75AADB", pch = 19)
  })

}

shinyApp(ui, server)


### this is the calculation on the raw data ----
### to present direct estimates

dat <-
  dat %>%
  mutate(setting = factor(setting),
         p_screen = `Total No Screened`/`Total No identified`,          #prop screened of identified for each incident
         p_ltbi = `Latent`/`Total No Screened`,
         cost = vtotal_year_cost(inc_sample = 1,
                                 id_per_inc = `Total No identified`,    #each incident cost
                                 screen_per_inc = `Total No Screened`,
                                 ltbi_per_inc = `Latent`),
         dcost_per_id = cost/`Total No identified`,
         dcost_per_screen = cost/`Total No Screened`,
         dcost_per_ltbi = cost/Latent,
         identified = `Total No identified`,
         screen = `Total No Screened`,
         latent = Latent,
         incidents = 1)
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

  output$contents <- renderTable({

    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    # https://shiny.rstudio.com/articles/upload.html

    req(input$file1)
    read.csv(input$file1$datapath)
  })

  ##TODO: what should the  if(!null bit be be??
  ## doesnt save anything atm
  output$savePlot <- shiny::downloadHandler(
    filename = function() {"Plot.png"}, #nolint
    content = function(file) {
      if (!is.null(plot_data)){
        png(file)
        print(plot(plot_data))
        dev.off()
      }
    }
  )

  output$save_counts <- shiny::downloadHandler(
    filename = function() {"output_counts.csv"},
    content = function(file) {
      if (!is.null(output$dat)) {
        write.csv(output$dat, file, row.names = FALSE)
      }
    }
  )

  output$save_costs <- shiny::downloadHandler(
    filename = function() {"output_costs.csv"},
    content = function(file) {
      if (!is.null(output$datcost)) {
        write.csv(output$datcost, file, row.names = FALSE)
      }
    }
  )

  output$dat <- renderTable(
    dat[, c("year", "setting", "Total No identified", "Total No Screened", "Latent", "p_screen", "p_ltbi")])
  output$datcost <- renderTable(
    dat[, c("year", "setting", "cost", "dcost_per_id", "dcost_per_screen", "dcost_per_ltbi")])

}

#shinyApp(ui, server)

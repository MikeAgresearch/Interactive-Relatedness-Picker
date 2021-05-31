# Interactive Relatedness Comparison 1.0 by Michael Bates
# This is designed to take a GRM and display it in browser with some easy to use filtering and sorting tools.


library(shiny)
library(shinyWidgets)
library(DT)
#Define max .csv input upload size
options(shiny.maxRequestSize = 50*1024^2)

# Define UI
ui <- fluidPage(
   
   # Application title
   titlePanel("Interactive Relatedness Comparison"),
   
   
   # Sidebar inputs
   sidebarLayout(
      
      #Define type and label of main display
      mainPanel(dataTableOutput("contents")),
      
      #Define layout of side panel     
      sidebarPanel(
         
         #Upload GRM file
         fileInput("file1", "Choose GRM File", accept= c(
          "text/csv",
          "text/comma-separated-values,text/plain",
          ".csv")),
         
         #Client can choose sires along x-axis
         pickerInput(
            inputId = "sireselect",
            label = "Select Sires",
            choices = "Please Upload GRM",
            multiple = TRUE,
            options = pickerOptions(actionsBox = TRUE, liveSearch = TRUE),
         ),
         
         #Client can choose dams along y-axis
         pickerInput(
            inputId = "damselect",
            label = "Select Dams",
            choices = "Please Upload GRM",
            multiple = TRUE,
            options = pickerOptions(actionsBox = TRUE, liveSearch = TRUE),
         ),
         
         #Show raw values
         checkboxInput("relatedness", "Show Values (will reset sorting)", value = FALSE),
         
         h4("Definitions"),
         h6("LOW - Animals are not directly related"),
         h6("MED - Animals are possibly half-sibs or grandparent-offspring"),
         h6("HIGH - Animals are possibly siblings or parent-offspring"),
         h6("VHIGH - Animals appear indistinguishable, if this is unexpected, please contact GenomNZ to discuss"),
         h4("Known issues"),
         h6("Must have at least two sires slected at all times, selecting single sire causes the 2-dimensional error"),
         h6("Large GRMS of hundreds of animals takes a long time to refresh both the selection lists and the table"),
         h6("After you have picked your hinds and sires it may display an error, but this quickly disappears as it loads the table"),
        )
      ),

   )


server <- function(input, output, session) {

   #Containing out as reactive so that when the input changes it is regenerated
   file3 <- reactive({
      rownames = TRUE
      inFile <- input$file1
      if (is.null(inFile))
         return(NULL)
      file2 <- read.csv(inFile$datapath)
      #shiney data table render was not showing row names correctly, changed to DT
      rownames(file2) <- file2[,1]
      #Remove first column which is now the rownames
      file2 <- file2[-c(1)]
      file2
   })
   #Wrapping updating the pickers into an observe function so that they are not forever updating
   observe({
      req(file3())
#      updatePickerInput(session, inputId = "damselect", choices = rownames(file3()), selected = rownames(file3()))
#      updatePickerInput(session, inputId = "sireselect", choices = colnames(file3()), selected = colnames(file3()))
      updatePickerInput(session, inputId = "damselect", choices = rownames(file3()), selected = NULL)
      updatePickerInput(session, inputId = "sireselect", choices = colnames(file3()), selected = NULL)
   })
   
   #Output uploaded table as data table
   output$contents <- renderDT({
      req(file3())
      
      #Create summarized data table (to be primary view unless raw values selected)
      newgrid <- as.data.frame(file3())
      
      #Generate summarised data table
      for (irow in 1:nrow(file3())){
         for (icol in 1:ncol(file3())){
            dig <- file3()[irow,icol]
            if (dig >= 0.8) {
               newgrid[irow,icol] <- "VHIGH"
            } else if (dig >= 0.3)  {
               newgrid[irow,icol] <- "HIGH"
            } else if (dig >= 0.1)  {
               newgrid[irow,icol] <- "MED"
            } else {
               newgrid[irow,icol] <- "LOW"
            }
         }
      }
      
      #Check box for raw values or not
      if (input$relatedness == TRUE){
         return(file3()[input$damselect,input$sireselect])
      }else {
         return(newgrid[input$damselect,input$sireselect])
      }
      
   })
}
   
    
# Run the application 
shinyApp(ui, server)

   

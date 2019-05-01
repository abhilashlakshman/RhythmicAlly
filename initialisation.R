is.installed <- function(mypkg) is.element(mypkg, installed.packages()[,1])


if (!require("plotly")) install.packages("plotly",dependencies = TRUE)
if (!require("shiny")) install.packages("shiny",dependencies = TRUE)
if (!require("shinydashboard")) install.packages("shinydashboard",dependencies = TRUE)
if (!require("zoo")) install.packages("zoo",dependencies = TRUE)
if (!require("RColorBrewer")) install.packages("RColorBrewer",dependencies = TRUE)
if (!require("pracma")) install.packages("pracma",dependencies = TRUE)
if (!require("zeitgebr")) install.packages("zeitgebr",dependencies = TRUE)


if (is.installed("plotly") & is.installed("shiny") & is.installed("shinydashboard") & is.installed("zoo") & is.installed("pracma") & is.installed("RColorBrewer") & is.installed("zeitgebr")){
  print(paste('Initialisation complete! RhythmicAlly is now ready for use'), quote=F)
} else {
  print(paste('Error: One or more packages may not have installed correctly'), quote=F)
}

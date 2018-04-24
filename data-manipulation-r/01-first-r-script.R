library(tidyverse)
library(historydata)
# If you are missing historydata or tidyverse, uncomment these lines and run them once
# install.packages(c("devtools", "tidyverse"))
# devtools::install_github("ropensci/historydata")

data("catholic_dioceses")

catholic_dioceses

View(catholic_dioceses)

unique(catholic_dioceses$rite)

catholic_dioceses %>% 
  filter(rite == "Byzantine") %>% 
  View

# Filter the table for a different rite

latin <- catholic_dioceses %>% 
  filter(rite == "Latin") 

# Create a variable for a different variable

ggplot(catholic_dioceses, aes(x = date, y = rite)) +
  geom_point() +
  labs(title = "Timeline of rites")

# Make a plot for a different variable

two_dioceses <- catholic_dioceses %>% 
  filter(rite %in% c("Chaldean", "Byzantine"))

ggplot(two_dioceses, aes(x = date, y = rite, color = rite)) +
  geom_point()

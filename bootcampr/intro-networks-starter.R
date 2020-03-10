# Install packages if we don't have them; otherwise, load the packages.
if (!require(tidyverse)) install.packages('tidyverse')
if (!require(tidygraph)) install.packages('tidygraph')
if (!require(ggraph)) install.packages('ggraph')
if (!require(influenceR)) install.packages('influenceR')

# Data prep ---------------------------------------------------------------

# We're going to build a network of character interactions from 
# the book series Game of Thrones. We'll start by loading in two datasets, one
# for edges and one for nodes.

edges <- read_csv("https://raw.githubusercontent.com/unolibraries/workshops/master/bootcampr/data/asoiaf-all-edges.csv")
got_nodes <- read_csv("https://raw.githubusercontent.com/unolibraries/workshops/master/bootcampr/data/asoiaf-all-nodes.csv")

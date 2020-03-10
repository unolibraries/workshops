# Working with network data using ggraph and tidygraph

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

# Let's take a look at our data first to get a sense of what's here. 
str(edges)
str(got_nodes)

edges %>% View()
got_nodes %>% View()

# Since there are so many characters in the books, let's filter the 100 characters
# that have the most interactions across all books. 

# Before we can apply a filter, we need to determine which characters have the
# most interactions. We'll do this by summarizing the 'weight' column.
main_ch <- edges %>% 
  select(-Type) %>% 
  gather(x, name, Source:Target) %>% 
  group_by(name) %>% 
  summarise(sum_weight = sum(weight)) %>% 
  ungroup() # ungroup lets us turn off the group_by -- sometimes the metadata
# included with the tibble can mess with other manipulations we do later.

# Once we have a summary of the weights, we need to then find the top 100 characters,
# which we will do using top_n
main_ch_top <- main_ch %>% 
  arrange(desc(sum_weight)) %>% 
  top_n(100, sum_weight)
main_ch_top

# Now that we know this, we can filter our overall dataset. 
got_edges <- edges %>% 
  filter(Source %in% main_ch_top$name & Target %in% main_ch_top$name)

# Network prep ------------------------------------------------------------

# tidygraph lets us manipulate node and edge data, but to do so our data needs
# to be a tbl_graph object. Once it's in this format, we can manipulate our data
# and calculate things like centrality or edge metrics. 

got_edges_tbl <- as_tbl_graph(got_edges, directed = FALSE)
class(got_edges_tbl)
got_edges_tbl

# tidygraph works by **activating** nodes and edges, allowing us to manipulate
# the data and add in new measures, etc. For example, maybe we want to remove
# all multiple edges. Remember: try out ?edge_is in RStudio and see what
# autocomplete suggests. 
got_edges_tbl %>% 
  activate(edges) %>% 
  filter(!edge_is_multiple())

# Network: Centrality -----------------------------------------------------

# centrality measures the importance of a node in a network. There are *many* ways
# in tidygraph to calculate centrality. See ?centrality for an overview. We're going
# to calculate centrality by degree (the number of edges a node has). 
got_edges_tbl %>% 
  activate(nodes) %>% 
  mutate(centrality = centrality_degree()) %>% 
  arrange(desc(centrality))

# Network: Clustering -----------------------------------------------------

# Another common operation in network science is community detection (or sometimes
# called graph topology) which looks for commonality in social network analysis. 
# tidygraph has several ways of doing this; see ?group_graph.
got_edges_tbl %>% 
  activate(nodes) %>% 
  mutate(group = group_infomap()) %>% 
  arrange(desc(group))

# Network: Node types -----------------------------------------------------

# We can also use tidygraph to query node types (see ?node_types). Let's look at
# the 'node_is_keyplayer()' to identify the top ten key players in the network.
got_edges_tbl %>% 
  activate(nodes) %>% 
  mutate(keyplayer = node_is_keyplayer(k = 10))

# Network: Betweenness ----------------------------------------------------

# Betweenness lets us look for the shortest path between nodes, giving us another
# kind of centrality measure to look at node importance.
got_edges_tbl %>% 
  activate(edges) %>% 
  mutate(centrality_edge = centrality_edge_betweenness())

# Network: Combined -------------------------------------------------------

# Now we combine everything from above into a new tbl_graph object using
# the tidyverse framework.
got_graph <- got_edges_tbl %>% 
  activate(nodes) %>% 
  mutate(centrality = centrality_degree(),
         group = group_infomap(),
         center = node_is_center(),
         dist_to_center = node_distance_to(node_is_center()),
         keyplayer = node_is_keyplayer(k = 10)) %>% 
  activate(edges) %>% 
  filter(!edge_is_multiple()) %>% 
  mutate(centrality_edge = centrality_edge_betweenness())

# If we want, we can convert this back into a data frame
got_graph %>% 
  activate(nodes) %>% as_tibble() %>% View()

# Network: Plotting -------------------------------------------------------

# For plotting the network, we are using ggraph, an extension of ggplot that supports
# the creation of networks, graphs, and trees. ggraph comes with its own geoms, 
# facets, layouts, and themes.

# First, we're going to define a layout for the network to use. For this, we'll use
# the Fruchterman-Reingold algorithm. 
layout <- create_layout(got_graph,
                        layout = "fr")
class(layout)

# We'll now call the ggraph function, which works similarly to a ggplot function.
ggraph(layout) +
  geom_edge_link(aes(width = weight), alpha = 0.2) +
  geom_node_point(aes(color = factor(group)), size = 2) +
  geom_node_text(aes(label = name), size = 3, repel = TRUE) +
  theme_graph()

# Narrate: So, what do we see in this? The groups almost reflect the narrative perfectly.
# The Night's Watch are grouped with Wildlings; Stannis, Davos, Selyse, and Melisandre
# form a group; Dany and her squad; the Martells are grouped together. The Greyjoys
# are grouped together. 

# Network: Centrality graph -----------------------------------------------

# For this, we want to plot the center-most characters in the network. We'll make
# the center most character a different color, and show distance to the center
# by changing the node size. 

# First, we're going to make our own color palette using Color Brewer
cols <- RColorBrewer::brewer.pal(3, "Set1")

ggraph(layout) +
  # TODO: step one: run the edge and node geoms first w/ aes()
  geom_edge_link(aes(width = weight), alpha = 0.2) +
  geom_node_point(aes(color = factor(center), size = dist_to_center)) +
  # TODO: step two: text
  geom_node_text(aes(label = name), size = 2, repel = TRUE) +
  scale_color_manual(values = c("red", "blue")) +
  theme_graph()

# Narrate: So what do we see in this graph? We can spot the two most central characters
# in the book: Robert Baratheon and Tyrion Lannister. 

# Layouts -----------------------------------------------------------------

ggraph(got_edges_tbl, layout = "linear", circular = TRUE) + # TODO: circular last
  geom_edge_arc(aes(width = weight), alpha = 0.2) +
  scale_edge_width(range = c(0.2, 2)) + # TODO: do next to last
  geom_node_point() +
  theme_graph()

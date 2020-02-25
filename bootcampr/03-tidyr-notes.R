# BootcampR: Introduction to R Workshop 
# University of Nebraska at Omaha
#
# Notes from our exercise using the tidyverse's dplyr and tidyr functions
# for working with flight data. 
# 
# date: 2020-02-25
# Jason A. Heppler | jasonheppler.org

library(tidyverse)
library(nycflights13)

data(flights)
flights

data(weather)
weather

data(airports)
airports 

# filter() ----------------------------------------------------------------


# Find all flights to SFO or OAK
sfo <- filter(flights, dest == "SFO" | dest == "OAK") %>% View()
#write_csv("~/Desktop/sfo.csv", sfo)
filter(flights, dest %in% c("SFO","OAK"))

# Find all flights in January 
filter(flights, month == 1)

#Find all flights delayed (dep_delay) by more than an hour 
filter(flights, dep_delay > 60)

#Find all flights that departed between midnight and 5 am
filter(flights, dep_time >= 0, dep_time <= 500)

#Find where the arrival delay (arr_delay) was more than 
# twice the departure delay
filter(flights, arr_delay > 2 * dep_delay)

# select() ----------------------------------------------------------------

select(flights, arr_delay, dep_delay)
select(flights, arr_delay:dep_delay)
select(flights, ends_with("delay"))
select(flights, contains("delay"))


# arrange() ---------------------------------------------------------------

#Order the flights by departure date (month, day) and time (dep_time).
arrange(flights, month, day, dep_time)

#Which flights were most delayed? (Hint: desc())
arrange(flights, desc(dep_delay))

#Which flights caught up the most time during the flight?
arrange(flights, desc(dep_delay - arr_delay))

# mutate() ----------------------------------------------------------------
flights <- mutate(flights, speed = distance / (air_time  / 60))
arrange(flights, desc(speed))

flights <- mutate(flights, delta = dep_delay - arr_delay)
arrange(flights, desc(delta))

# summarize() -------------------------------------------------------------
by_date <- group_by(flights, year, month, day)
summarize(filter(by_date, !is.na(dep_delay)),
          med = median(dep_delay),
          mean = mean(dep_delay),
          max = max(dep_delay),
          q90 = quantile(dep_delay, 0.9),
          delay = mean(dep_delay > 0))

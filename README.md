# UNO Workshops

This repository contains data and resources for workshops taught by University of Nebraska at Omaha Libraries. We hope you'll use the material here for your own workshops. Content and data is available under the [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/) (unless otherwise noted in a specific folder), and the code is available under the [MIT License](http://opensource.org/licenses/MIT).

## Workshops

Event                   | Workshop                 | Date(s)       | Folder
----------------------- | ------------------------ | ------------- | -----------
UNO Libraries Professional Development Series | Introduction to Palladio | March 9, 2017 | [palladio](palladio)
Endangered Data Week | Web Scraping with R | April 18, 2017 | [web-scraping-r](web-scraping-r)
Endangered Data Week | Introduction to Github | April 19, 2017 |
Endangered Data Week | Data Manipulation with R | April 20, 2017 | [data-manipulation-r](data-manipulation-r)
Graduate Studies Workshops | Introduction to Data Visualization | September 7, 2017 | [intro-data-viz](intro-data-viz)
ENGL 3000 | Introduction to Palladio | February 13, 2018 | [palladio](palladio)
Endangered Data Week | Data Manipulation with R | February 26, 2018 | [data-manipulation-r](data-manipulation-r)
Endangered Data Week | Data Visualization with R | February 28, 2018 | [data-visualization-r](data-visualization-r)
HIST 4900            | Introduction to R         | April 25, 2018    | [data-manipulation-r](data-manipulation-r)
UNO Libraries        | Collect & Prep Your Data for Visualization and Analysis with R | November 8, 2018    | [data-manipulation-r](data-manipulation-r)
UNO Libraries        | Information Visualization with RAW | November 15, 2018    | `information-visualization-raw` 

## Digital Ocean setup for R workshops

Create a new Digital Ocean droplet, making sure to have SSH available and
selecting Ubuntu as your Linux distro.

```
sudo apt-get update
sudo apt-get -y install r-base libapparmor1 gdebi-core libcurl4-openssl-dev libssl-dev libxml2-dev nginx
wget https://download2.rstudio.org/rstudio-server-1.0.136-amd64.deb
sudo gdebi rstudio-server-1.0.136-amd64.deb
sudo adduser <user>

sudo apt-get install libcurl4-openssl-dev libssl-dev libxml2-dev
```

Then install the needed packages.

```
install.packages(c('tidyverse','rmarkdown'), repos='http://cran.rstudio.com',
dependencies = TRUE)
```

### Rstudio clean URL

Make sure nginx is installed.

```
sudo apt-get update
sudo apt-get -y install nginx
```

Edit the config file:

```
$ sudo vim /etc/nginx/sites-enabled/default
```

Delete the contents here, and replace with:

```
server {
  listen 80; 

  location /rstudio/ {
    rewrite ^/rstudio/(.*)$ /$1 break;
    proxy_pass http://localhost:8787;
    proxy_redirect http://localhost:8787/ $scheme://$host/rstudio/;
  }
}
```

Then restart nginx for the changes to take place.

```
sudo service nginx restart
```

### Add a swap file to manage memory

```
cd /var
touch swap.img
chmod 600 swap.img

dd if=/dev/zero of=/var/swap.img bs=1024k count=1000

mkswap /var/swap.img

swapon /var/swap.img

swapoff /var/swap.img
```

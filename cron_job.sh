#!/bin/bash

set -e 

cd /srv/shiny-server/la-city/311-analysis

wget -P ./data/ "https://data.lacity.org/api/views/d4vt-q4t5/rows.csv?accessType=DOWNLOAD"
rm ./data/MyLA311_Service_Request_Data_2017.csv
mv ./data/rows.csv?accessType=DOWNLOAD ./data/MyLA311_Service_Request_Data_2017.csv

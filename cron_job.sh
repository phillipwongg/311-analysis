#!/bin/bash

set -e 

wget -P /home/ubuntu/311-analysis/data/ "https://data.lacity.org/api/views/d4vt-q4t5/rows.csv?accessType=DOWNLOAD"
rm /home/ubuntu/311-analysis/data/MyLA311_Service_Request_Data_2017.csv
mv /home/ubuntu/311-analysis/data/rows.csv?accessType=DOWNLOAD /home/ubuntu/311-analysis/data/MyLA311_Service_Request_Data_2017.csv

#!/bin/python 

## A script that generates dataframes for 311. 

import pandas as pd 
#import feather
import requests

def get_data():
    ## download the data
    pass

data_2017 = pd.read_csv('./data/MyLA311_Service_Request_Data_2017.csv')
data_2016 = pd.read_csv('./data/MyLA311_Service_Request_Data_2016.csv')

merged = pd.concat([data_2017, data_2016])


    

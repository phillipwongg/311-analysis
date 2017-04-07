# 311-analysis

Shiny Dashboard produced by USC Marshall Business School Students for 311 project/ITA analysis project. Currently working on building key charts (see [issue tracker](https://github.com/datala/311-analysis/issues)) for the deployed version/ITA analysis project 

## Installing 

You'll need the R packages install before you start. Additionally, you'll need 2016 and 2017 311 Service Request Data in CSV format in the data folder. Go to [data.lacity.org](http://data.lacity.org) to find the 311 data. 

If you want the data to automatically update, you'll need to use the `cron_job.sh` script. 

## Docs

`projects` contains git submodule for each USC student repo projects and their reports. 

`R` contains the final data loading scripts. 

`data` contains most of the data, except for the 311 data which you can download by running `cron_job.sh`. 

`app.R` is the main Shiny app. 

`www` contains web stylesheets. 

## Contributing

See `Contributing.md`

## Contact 

Hunter Owens (hunter.owens@lacity.org)

#------------------------------------Load libraries-------------------------------------------------
if(!require('rentrez')) install.packages('rentrez'); library(rentrez)
if(!require('dplyr')) install.packages('dplyr'); library(dplyr)
if(!require('XML')) install.packages('XML'); library(XML)
if(!require('metagear')) install.packages('metagear'); library(metagear)
#---------------------------------------Directory---------------------------------------------------
folderdir = "Retirement transitions and health/" # folder directory for that project
reviewer = "jem"
#------------------------------------Data extraction------------------------------------------------
# Define MeSH terms and time range
search_term     = "(Retirement transitions) AND (Health OR Healthcare OR Cost OR Utility OR Chronic OR Deaths) AND 2019:2020[PDAT]"
search          = entrez_search(db = "pubmed", term = search_term, retmax = 100)
multi_summary   =  entrez_summary(db = "pubmed", id = search$ids)
date_and_cite   = extract_from_esummary(multi_summary, c("pubdate","title","articleids"))
#--------------------------------------------------------------------------------------------------
source('01 get_reviews.R')
Sys.sleep(60) # let the system sleep for a while to ensure that the csv file created above is updated
source('02 get_reviews.R')
#--------------------------------------------------------------------------------------------------
#------------------------------------Load libraries-------------------------------------------------
if(!require('rentrez')) install.packages('rentrez'); library(rentrez)
if(!require('dplyr')) install.packages('dplyr'); library(dplyr)
if(!require('XML')) install.packages('XML'); library(XML)
if(!require('metagear')) install.packages('metagear'); library(metagear)
#---------------------------------------Directory---------------------------------------------------
# folder directory for that project
folderdir = "outputs/tb/" 
reviewer = "jem"
#------------------------------------Data extraction------------------------------------------------
# Define MeSH terms and time range
search_term     = "(Tuberculosis projections) AND (Case rates OR incidence OR population) AND 2015:2020[PDAT]"
search          = entrez_search(db = "pubmed", term = search_term, retmax = 200)
multi_summary   =  entrez_summary(db = "pubmed", id = search$ids)
date_and_cite   = extract_from_esummary(multi_summary, c("pubdate","title","articleids"))
#--------------------------------------------------------------------------------------------------
# Run each source code separately
# Part 1: pull out all the literature relevant to your literature reivew
source('codes/01 screening_abstract.R')

# Note: ensure that you screened the abstract before running the next step
# Part 2: collect the pdf of the papers
source('codes/02 collect_pdf.R')
#--------------------------------------------------------------------------------------------------
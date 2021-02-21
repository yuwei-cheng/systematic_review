# Systematic Review

This repos hopes to provide an introduction for paper extraction in systematic review

You can find the code in ./code/review.R

In general, this tutorial introduces

- How to search paper from database, for example, PubMed based on your defined MeSH term and date range by using R library(rentrez)
- How to fetch abstracts by using R library(XML)
- How to screen abstracts to decide which paper to include by using R library(metagear)
- How to download included paper and save their names in a systematic way (for example, ENTREZ ID) by using R library(metagear)
            
Notice that we need to mannually download articles if they are not open access (not free)

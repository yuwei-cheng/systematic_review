#------------------------------------Load libraries-------------------------------------------------
library(rentrez)      # Collect abstract and paper                     
library(dplyr)        # Data manipulation
library(XML)          # Fetch abstract data
library(metagear)     # Paper screening
#------------------------------------Data extraction------------------------------------------------
# Step 1: define MeSH terms and time range
search_term     = "(Japanese Encephalitis [MeSH]) AND (Fatalities OR Fatal OR Mortalities OR Mortal OR Letal OR Lethalities OR Deaths OR Die OR Died OR Dies OR Dead)AND 2018:2020[PDAT]"
fatality_search = entrez_search(db = "pubmed", term = search_term, retmax = 1000)
multi_summary   =  entrez_summary(db = "pubmed", id = fatality_search$ids)
date_and_cite   = extract_from_esummary(multi_summary, c("pubdate","title","articleids"))

# There are 62 JE papers between 2018 and 2020
# Latest data access Feb 21 2021
#------------------------------------Check DOI------------------------------------------------------
for(i in 1:dim(date_and_cite)[2]) # dim(date_and_cite)[2] is the number of collected articles
{
  if((date_and_cite[[3,i]] %>%
      subset(idtype=="doi") %>% select(value) %>% unlist() %>% length()) !=0)
  {
    date_and_cite[[3,i]] <-date_and_cite[[3,i]] %>% # only keep doi
      subset(idtype=="doi") %>% select(value) %>% unlist()
  }else{date_and_cite[[3,i]] <- NA}
}

#-------------------------------------Manage search result------------------------------------------
search_result = list()
search_result$pubdate = unlist(t(date_and_cite))[1:dim(date_and_cite)[2]]
search_result$title   = unlist(t(date_and_cite))[(dim(date_and_cite)[2]+1):(2*dim(date_and_cite)[2])]
search_result$doi     = unlist(t(date_and_cite))[(2*dim(date_and_cite)[2]+1):(3*dim(date_and_cite)[2])]
search_result$EntrezUID = fatality_search$ids
search_result = as.data.frame(search_result)
search_result = search_result %>% arrange(desc(pubdate))
#-------------------------------------Define abstracts function------------------------------------
extract_abstract_func = function(pm_data)
{
  PM_id = pm_data$EntrezUID
  fetch_pubmed = entrez_fetch(db = "pubmed", id = PM_id,rettype = "xml", parsed = T)
  abstracts = xpathApply(fetch_pubmed, '//PubmedArticle//Article', 
                         function(x) xmlValue(xmlChildren(x)$Abstract)) 
  # is used to apply a function to each
  # of those nodes, e.g. find nodes named "a anywhere in the tree that have 
  # an "href" attribute and get the value
  # of that attribute
  names(abstracts) = PM_id
  col_abstracts = do.call(rbind, abstracts) # rbind every elements inside abstracts 
  abstract_avai = cbind(as.character(pm_data[!is.na(col_abstracts),"title"]),
                        as.character(pm_data[!is.na(col_abstracts),"doi"]),
                        as.character(pm_data[!is.na(col_abstracts),"pubdate"]),
                        as.character(pm_data[!is.na(col_abstracts),"EntrezUID"]),
                        col_abstracts[!is.na(col_abstracts),])
  colnames(abstract_avai) = c("TITLE","DOI","PUBDATE","ENTREZUID","ABSTRACT")
  abstract_na <- pm_data[is.na(col_abstracts),]
  return(list(abstract_avai, abstract_na))
}
#-------------------------------------Extract abstracts---------------------------------------------
# Not very stable, sometimes need to try several times
fatality_abstract = extract_abstract_func(search_result)
# Results with abstracts:
write.csv(x = fatality_abstract[[1]],
          file = "./outputs/fatality_abstract_18_to_20.csv",
          row.names = F)
# Results without abstracts:
write.csv(x = fatality_abstract[[2]], 
          file = "./outputs/fatality_abstract_NA_18_to_20.csv", 
          row.names = F)
# Create your paper review file
invisible(effort_distribute(fatality_abstract[[1]], initialize = TRUE,
                  reviewers = "yuwei", # change to your name
                  save_split = TRUE,
                  directory = "./outputs"))
#--------------------------------------Screening abstracts------------------------------------------
# An API will pop up, select Yes, Maybe, or No
abstract_screener("./outputs/effort_yuwei.csv", aReviewer = "yuwei")

# Load the screened results and download the paper
paper_to_collect = read.csv("./outputs/paper_screening/effort_yuwei.csv")
paper_to_collect = paper_to_collect %>% subset(INCLUDE=="YES")
collection_outcomes = PDFs_collect(paper_to_collect, DOIcolumn = "DOI", 
                                   FileNamecolumn = "ENTREZUID", # save file name and entrez id 
                                   quiet = TRUE,
                                   directory = "./paper") # directory to save your paper 
# View download results from downloadOutcomes
# 13,14,23,33 needs manual downloading
# TODO: step 1: manually download the article
#       step 2: extract data and create JE_data_yuwei_18_to_20.csv
mannual_extract = collection_outcomes$STUDY_ID[collection_outcomes$downloadOutcomes != "downloaded"]
sink("./outputs/mannual_collection.txt")
paper_to_collect %>% subset(STUDY_ID %in% mannual_extract) %>% select(TITLE,ENTREZUID)
sink()
# An Outbreak Of Japanese Encephalitis In A Non-Endemic Region Of North-East India
# 29741521 already included
# Entomological Investigation Of Japanese Encephalitis Outbreak In Malkangiri District Of Odisha State India
# 29768623 already included 
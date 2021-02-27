#------------------------------------Check DOI------------------------------------------------------
i = 1
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
search_result = list(
  pubdate = unlist(t(date_and_cite))[1:dim(date_and_cite)[2]],
  title   = unlist(t(date_and_cite))[(dim(date_and_cite)[2]+1):(2*dim(date_and_cite)[2])],
  doi     = unlist(t(date_and_cite))[(2*dim(date_and_cite)[2]+1):(3*dim(date_and_cite)[2])],
  EntrezUID = search$ids
)
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
if(!file.exists(paste0(folderdir, 'outputs/'))) dir.create(paste0(folderdir, 'outputs/'))

abstract = extract_abstract_func(search_result)
# Results with abstracts:
write.csv(x = abstract[[1]],
          file = paste0(folderdir, "/outputs/abstract.csv"),
          row.names = F)
# Results without abstracts:
write.csv(x = abstract[[2]], 
          file = paste0(folderdir, "/outputs/abstract_NA.csv"),
          row.names = F)
# Create your paper review file
invisible(effort_distribute(abstract[[1]], initialize = TRUE,
                            reviewers = reviewer, # change to your name
                            save_split = TRUE,
                            directory = paste0(folderdir, "outputs")))

#--------------------------------------Screening abstracts------------------------------------------
# An API will pop up, select Yes, Maybe, or No
path_effort = paste0(folderdir, "outputs/effort_", reviewer, ".csv")
abstract_screener(path_effort, aReviewer = reviewer)


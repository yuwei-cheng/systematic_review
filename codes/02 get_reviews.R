# Load the screened results and download the paper
# will only download open access papers


## break down the collection to write an error, and go back to the next iteration
## indicate within the csv file to indicate if successfully collected

## consider pdf collection on its own

if(!file.exists(paste0(folderdir, 'papers/'))) dir.create(paste0(folderdir, 'papers/'))
paper_to_collect = read.csv(path_effort)
paper_to_collect = paper_to_collect %>% subset(INCLUDE=="YES")
collection_outcomes = PDFs_collect(paper_to_collect, DOIcolumn = "DOI", 
                                   FileNamecolumn = "TITLE", # save file name and entrez id 
                                   quiet = TRUE,
                                   directory = paste0(folderdir, "papers")) # directory to save your paper 

#--------------------------------------Screening abstracts------------------------------------------
mannual_extract = collection_outcomes$STUDY_ID[collection_outcomes$downloadOutcomes != "downloaded"]
manual = paper_to_collect %>% subset(STUDY_ID %in% mannual_extract) %>% select(TITLE,ENTREZUID,DOI)
write.csv(x = manual,
          file = paste0(folderdir, "outputs/manual_collect_paper.csv"),
          row.names = F)

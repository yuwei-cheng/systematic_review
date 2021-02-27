## Load the screened results and download the paper
## will only download open access papers

## papers will only be downloaded if pdf_collect function did not give an error

path_effort = paste0(folderdir, "outputs/effort_", reviewer, ".csv")
if(!file.exists(paste0(folderdir, 'papers/'))) dir.create(paste0(folderdir, 'papers/'))
paper_to_collect = read.csv(path_effort, header = TRUE, sep = ',')
paper_to_collect = paper_to_collect %>% subset(INCLUDE=="YES")

collection_outcomes = data.frame(paper_to_collect, downloadOutcomes = 0)
i = 1
for(i in 1:nrow(paper_to_collect)){
  
  print(i)
  
  # first identify if its an error, if its not, then save the results
  if_error = tryCatch(PDFs_collect(paper_to_collect[i, ], DOIcolumn = "DOI", 
                               FileNamecolumn = "TITLE", # save file name and entrez id 
                               quiet = TRUE,
                               directory = paste0(folderdir, "papers")), # directory to save your paper 
                  error = function(e) {
                    print(e)
                    return("error")
                    #next
                  })
  
  # saving non-error results
  if(if_error != 'error'){
    collection_outcomes[i, ] = if_error[1, ]
  } else { 
    # saving error results
    print ('Error bro!')
    collection_outcomes[i, 'downloadOutcomes'] = 'looperror'
  }
  
  
}

print('Downloaded complete! Please check output folder.')

#--------------------------------------Screening abstracts------------------------------------------
mannual_extract = collection_outcomes$STUDY_ID[collection_outcomes$downloadOutcomes != "downloaded"]
manual = paper_to_collect %>% subset(STUDY_ID %in% mannual_extract) %>% select(TITLE,ENTREZUID,DOI)
write.csv(x = manual,
          file = paste0(folderdir, "outputs/manual_collect_paper.csv"),
          row.names = F)

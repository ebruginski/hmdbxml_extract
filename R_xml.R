library(xml2)
library(magrittr)
start_time <- Sys.time()
# the contents of sample.xml are parsed
hmdb_metabolites <- read_xml('data/hmdb/serum_metabolites.xml');

met.nodes <- xml_find_all(hmdb_metabolites, './/d1:metabolite');

xpath_child.v <- c('./d1:accession',
                   './d1:name',
                   './d1:kegg_id',
                   './d1:average_molecular_weight',
                   './d1:chemical_formula');
#what names should they get in the list?
child.names.v <- c('CPD_NAME','KEGG_ID','MOL_WEIGHT', 'CHEM_FORM');

gc()

hmdb.cpd <- NULL
pb <- txtProgressBar(0, length(met.nodes), style = 3)

for (i in 1:length(met.nodes)){
  setTxtProgressBar(pb, i)
  #first, loop over the met.nodes
  hmdb.cpd[i] <- lapply(met.nodes[i], function(x) { 
  #second, loop over the xpath desired child-nodes
  temp <- lapply(xpath_child.v, function(y) { 
    xml_find_all(x,y) %>% xml_text() %>% data.frame(value = .)
  });
  #set their names
  names(temp) = child.names.v;
  return(temp);
});
}
close(pb)
end_time <- Sys.time()
total_tim <- end_time - start_time


hmdb.csv<- data.frame(matrix(unlist(hmdb.cpd), nrow=length(hmdb.cpd), byrow=TRUE));

colnames(hmdb.csv) <- c('HMDB_ID', 
                       'CPD_NAME', 
                       'KEGG_ID', 
                       'MOL_WEIGHT', 
                       'CHEM_FORM');

write.table(hmdb.csv, 'data/hmdb.csv', row.names = FALSE, quote = FALSE, sep = ';')

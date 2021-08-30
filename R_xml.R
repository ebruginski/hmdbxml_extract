# bibliotecas
library(xml2)
library(magrittr)
# tempo inicial
start_time <- Sys.time()
# importar e fazer o parse do arquivo .xml
hmdb_metabolites <- read_xml('serum_metabolites.xml');
# extrair os nodes do arquivo xml
met.nodes <- xml_find_all(hmdb_metabolites, './/d1:metabolite');
# definir os campos que serão extraídos
xpath_child.v <- c('./d1:accession',
                   './d1:name',
                   './d1:kegg_id',
                   './d1:average_molecular_weight',
                   './d1:chemical_formula');
# nomes que serão colocados na lista 
child.names.v <- c('CPD_NAME',
                   'KEGG_ID',
                   'MOL_WEIGHT',
                   'CHEM_FORM');
# limpar a memória
gc()
# criar o espaço na memória
hmdb.cpd <- NULL
# barra de progresso
pb <- txtProgressBar(0, length(met.nodes), style = 3)
# loop para a extração dos dados
for (i in 1:length(met.nodes)){
  setTxtProgressBar(pb, i)
  #primeiro loop nos nodes primários
  hmdb.cpd[i] <- lapply(met.nodes[i], function(x) { 
  #segundo, loop para a seleção das informações(child-nodes)
  temp <- lapply(xpath_child.v, function(y) { 
    xml_find_all(x,y) %>% xml_text() %>% data.frame(value = .)
  });
  #definir os nomes
  names(temp) = child.names.v;
  return(temp);
});
}
close(pb)
# tempo final
end_time <- Sys.time()
# tempo total
total_tim <- end_time - start_time
# transforma a lista em dataframe
hmdb.csv<- data.frame(matrix(unlist(hmdb.cpd), nrow=length(hmdb.cpd), byrow=TRUE));
# define o nome das colunas
colnames(hmdb.csv) <- c('HMDB_ID', 
                       'CPD_NAME', 
                       'KEGG_ID', 
                       'MOL_WEIGHT', 
                       'CHEM_FORM');
# grava os dados em um arquivo de texto .csv
write.table(hmdb.csv, 'data/hmdb.csv', row.names = FALSE, quote = FALSE, sep = ';')

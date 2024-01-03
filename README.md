# Calderon2019ATACmodel
Example scripts to train, assess, and interpret CNN model architectures on ATAC-seq data from Calderon et al. 2019.

The count matrix with aligned ATAC-seq Tn5 cuts can be downloaded from the Gene Expression Omnibus (GEO: [GSE118189](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE118189)) ([Calderon et al. 2019](https://www.nature.com/articles/s41588-019-0505-9)). The [data matrix](https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE118189&format=file&file=GSE118189%5FATAC%5Fcounts%2Etxt%2Egz) contains 175 measurements for 829,942 genomic regions (peaks), spanning 45 unique human immune cell states from eleven different donors. The 45 immune cell states cover 25 resting cell types of which 20 are also included as stimulated cell states (Immature NK, Memory NK, Myeloid DC, Plasmablasts, and pDC don’t have a measured stimulated state). 

Follow steps in `data_processing.sh` to normalize the count matrix, i.e. taking the log2 of the counts, quantile normalize all samples, and compute the mean expression for all cell states across donors. 

Since our models usually focus on predicting differences between cell types, we exclude irreproducible ATAC peaks and only train our models on peaks that are not affected by a donor’s genotype or trans-actin factors. To select reprocible peaks, we compute the correlation between two sets of different donors across all 45 cell types for each peak for 100 different pairs of donor sets, and only keep peaks with a consistent positive correlation allowing for a false discovery rate of 0.1% (T-test, n=100, Bejamini-Hochberg correction). 

CNN models were trained as described in `train_cnns.sh` with code the code repository in https://github.com/LXsasse/DRG/

Model performance was analyzed as described in `assess_model.sh`. 

Gene regulatory grammar was identified as described in `interpret_cnn.sh`

Variant effect predictions can be performed as described in `pred_cnn.sh`

Parameters of the trained models can found in `/Models` and be loaded into the model for global analysis or sequence analysis as described in `interpret_cnn.sh` and `pred_cnn.sh`.

Mouse ATAC-seq data can be found here https://github.com/smaslova/AI-TAC/
or the processed data files can be downloaded individually using the following links:
- [bed file containing peak locations](https://www.dropbox.com/s/r8drj2wxc07bt4j/ImmGenATAC1219.peak_matched.txt?dl=0)
- [csv file containing measured ATAC-seq peak heights](https://www.dropbox.com/s/7mmd4v760eux755/mouse_peak_heights.csv?dl=0)




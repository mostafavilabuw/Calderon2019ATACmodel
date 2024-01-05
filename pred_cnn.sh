


# One-hot encoded sequence file
infile=Peak400.npz
# ATAC Tn5 cuts per peak
outfile=ATACcounts.csv

# test set 
cv=1
# Test, validation and training set assigment file
cvfile='GSE118189_ATAC_counts.txt_w400_enformer_testsets.txt'

# batchsize
bs=64

# training hardware
device='cuda:0'


# location of script for model training
codedir=/loc/of/drg/scripts/DRG/models/

# list of data points that pass quality control 
sellist=GSE118189_ATAC_counts.txt.btwsetscorradjp_gt3.txt

# list of data points that we want to inspect with base pair attributions
testlist=Testseqlist.txt

modelparams=Models/ATACcountsonPeak400rcomp-cv10-1_Cormsek256l15FfGELUrcTvlCotasft101_dc5i1d1-2-4-8-16s1l7r1_tc4dNoned1s1r1l7mw3nfc3s512cbnoTfdo0.1tr1e-05SGD0.9bs64-F_model_params.dat

# Load model and compute per base attributions 
python ${codedir}cnn_model.py $infile None --delimiter ',' --reverse_complement --outdir Models/ --predictnew --select_list $testlist --cnn $modelparams 'device='${device}'+batchsize='${bs} --ism all --deeplift all --outname Models/TestseqAttrib

# Load model and predict ATAC counts for the sequences in the testset
python ${codedir}cnn_model.py $infile $outfile --delimiter ',' --reverse_complement --outdir Models/ --crossvalidation $cvfile $cv 10 --select_list $sellist --cnn $modelparams 'device='${device}'+batchsize='${bs} --save_predictions



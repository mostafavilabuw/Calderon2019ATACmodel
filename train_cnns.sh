
# One-hot encoded sequence file
infile=Peak400.npz
# ATAC Tn5 cuts per peak
outfile=ATACcounts.csv

# test set 
cv=1
# Test, validation and training set assigment file
cvfile='GSE118189_ATAC_counts.txt_w400_enformer_testsets.txt'


# batch size
bs=64
# learning rate
lr='1e-5'
# number of epochs without test set loss improvement before early stopping
patience=15
# total number of epochs if early stopping is not used
epochs=1000

# parameter describing the model optimization
opt='SGD+optim_params=0.9+warm_up_epochs=5'

# training loss function
loss=Correlationmse
# validation loss
valloss=Correlationdata

# data augmentation
dopt='shift_sequence=10+random_shift=True'


# training hardware
device='cuda:0'

# number of kernels
nker=256
# size of initial kernels
lker=15

# final transformation after prediction head
outfunc='Linear' # No transformation 

# location of script for model training
codedir=/loc/of/drg/scripts/DRG/models/

# list of data points that pass quality control 
sellist=GSE118189_ATAC_counts.txt.btwsetscorradjp_gt3.txt



# shallow CNN
#echo '++++++++++ shallow CNN +++++++++'
time python ${codedir}cnn_model.py $infile $outfile --delimiter ',' --reverse_complement --outdir Models/ --crossvalidation $cvfile $cv 10 --select_list $sellist --cnn 'loss_function='${loss}'+validation_loss='${valloss}'+optimizer='${opt}'+num_kernels='${nker}'+kernel_bias=False+l_kernels='${lker}'+kernel_function=GELU+max_pooling=False+weighted_pooling=True+pooling_size=81+outclass='${outfunc}'+'${dopt}'+epochs='${epochs}'+patience='${patience}'+batchsize='${bs}'+lr='${lr}'+write_steps=1+device='${device}'+keepmodel=True' --save_correlation_perclass --save_correlation_pergene


# residual CNN
#echo '++++++++++ residual CNN +++++++++' >> $ctrl
time python ${codedir}cnn_model.py $infile $outfile --delimiter ',' --reverse_complement --outdir Models/ --crossvalidation $cvfile $cv 10 --select_list $sellist --cnn 'loss_function='${loss}'+validation_loss='${valloss}'+optimizer='${opt}'+num_kernels='${nker}'+kernel_bias=False+l_kernels='${lker}'+kernel_function=GELU+max_pooling=False+weighted_pooling=False+pooling_size=1+dilated_convolutions=5+l_dilkernels=7+dilations=1+conv_increase=1.+dilweighted_pooling=2+fclayer_size=512+nfc_layers=3+outclass='${outfunc}'+'${dopt}'+epochs='${epochs}'+patience='${patience}'+batchsize='${bs}'+lr='${lr}'+write_steps=1+device='${device}'+conv_batch_norm=True+fc_dropout=0.1+keepmodel=True' --save_correlation_perclass --save_correlation_pergene 

# dilated residual CNN
#echo '++++++++++ Deep CNN +++++++++' >> $ctrl
time python ${codedir}cnn_model.py $infile $outfile --delimiter ',' --reverse_complement --outdir Models/ --crossvalidation $cvfile $cv 10 --select_list $sellist --cnn 'loss_function='${loss}'+validation_loss='${vallos}'+optimizer='${opt}'+num_kernels='${nker}'+kernel_bias=False+l_kernels='${lker}'+kernel_function=GELU+max_pooling=False+weighted_pooling=False+pooling_size=1+dilated_convolutions=5+l_dilkernels=7+dilations=[1,2,4,8,16]+transformer_convolutions=4+trdilations=1+l_trkernels=7+trweighted_pooling=3+fclayer_size=512+nfc_layers=3+outclass='${outfunc}'+'${dopt}'+epochs='${epochs}'+patience='${patience}'+batchsize='${bs}'+lr='${lr}'+write_steps=1+device='${device}'+conv_batch_norm=True+fc_dropout=0.1+keepmodel=True+init_adjust=False' --save_correlation_perclass --save_correlation_pergene 

mousein=mouseATAC_seq401.npz 
mouseout=mouseATAC.csv
mousecv=ImmGenATAC1219.peak_matched_enformer_testsets.txt

# dilated residual CNN with mouse data
#echo '++++++++++ Deep CNN with mouse +++++++++' >> $ctrl
time python ${codedir}cnn_model.py $mousein $mouseout --delimiter ',' --reverse_complement --outdir Models/ --crossvalidation $mousecv $cv 10 --cnn 'loss_function='${loss}'+validation_loss='${valloss}'+optimizer='${opt}'+num_kernels='${nker}'+kernel_bias=False+l_kernels='${lker}'+kernel_function=GELU+max_pooling=False+weighted_pooling=False+pooling_size=1+dilated_convolutions=5+l_dilkernels=7+dilations=[1,2,4,8,16]+transformer_convolutions=4+trdilations=1+l_trkernels=7+trweighted_pooling=3+fclayer_size=512+nfc_layers=3+outclass='${outfunc}'+'${dopt}'+epochs='${epochs}'+patience='${patience}'+batchsize='${bs}'+lr='${lr}'+write_steps=1+device='${device}'+conv_batch_norm=True+fc_dropout=0.1+keepmodel=True' --save_correlation_perclass --save_correlation_pergene 

mousepthfile=Models/mouseATAConseq401rcomp-cv10-1_Cormsek256l15FfGELUrcTvlCotasft101_dc5i1d1-2-4-8-16s1l7r1_tc4dNoned1s1r1l7mw3nfc3s512cbnoTfdo0.1tr1e-05SGD0.9bs64-F_parameter.pth

# dilated residual CNN with mouse model as starting parameters
#echo '++++++++++ Deep CNN +++++++++' >> $ctrl
time python ${codedir}cnn_model.py $infile $outfile --delimiter ',' --reverse_complement --outdir Models/ --crossvalidation $cvfile $cv 10 --maketestvalset --select_list $sellist --cnn 'loss_function='${loss}'+validation_loss='${valloss}'+optimizer='${opt}'+num_kernels='${nker}'+kernel_bias=False+l_kernels='${lker}'+kernel_function=GELU+max_pooling=False+weighted_pooling=False+pooling_size=1+dilated_convolutions=5+l_dilkernels=7+dilations=[1,2,4,8,16]+transformer_convolutions=4+trdilations=1+l_trkernels=7+trweighted_pooling=3+fclayer_size=512+nfc_layers=3+outclass='${outfunc}'+'${dopt}'+epochs='${epochs}'+patience='${patience}'+batchsize='${bs}'+lr='${lr}'+write_steps=1+device='${device}'+conv_batch_norm=True+fc_dropout=0.1+keepmodel=True+init_adjust=False' --save_correlation_perclass --save_correlation_pergene --load_parameters $mousepthfile None classifier.classifier.Linear.weight,classifier.classifier.Linear.bias False False --outname Models/InitMouse





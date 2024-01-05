
# File names of model files
shallow=ATACcountsonPeak400rcomp-cv10-1_Cormsek256l15FfGELUwei81rcTvlCotasft101tr0.0001SGD0.9bs64-F
residual=ATACcountsonPeak400rcomp-cv10-1_Cormsek256l15FfGELUrcTvlCotasft101_dc5i1d1s1l7dw2r1nfc3s512cbnoTfdo0.1tr1e-05SGD0.9bs64-F
deep=ATACcountsonPeak400rcomp-cv10-1_Cormsek256l15FfGELUrcTvlCotasft101_dc5i1d1-2-4-8-16s1l7r1_tc4dNoned1s1r1l7mw3nfc3s512cbnoTfdo0.1tr1e-05SGD0.9bs64-F
deepmouse=InitMouse-cv10-1_Cormsek256l15FfGELUrcTvlCotasft101_dc5i1d1-2-4-8-16s1l7r1_tc4dNoned1s1r1l7mw3nfc3s512cbnoTfdo0.1tr1e-06SGD0.9bs64-F

# File with adjusted p-value for replicate correlation of each peak
replica=../GSE118189_ATAC_counts.txt.lnorm.qntlnorm.btwsetscorradjp.txt

codedir=/loc/of/drg/scripts/DRG/visualize_performance/

# boxplot for distribution of correlations for cell states
python ${codedir}assess_model.py ${shallow}_exper_corr_tcl0.txt,${residual}_exper_corr_tcl0.txt,${deep}_exper_corr_tcl0.txt 'Shallow CNN,Residual CNN,Deep dilated residual CNN' --similarity --ylabel "Pearson R cell type" --plot_distribution swarm=True+connect_swarm=False --print_mean --savefig Modelcomparison_celltypepearson

# boxplot for distribution of correlations for peak regions
python3 ${codedir}assess_model.py ${shallow}_gene_corr_tcl0.txt,${residual}_gene_corr_tcl0.txt,${deep}_gene_corr_tcl0.txt 'Shallow CNN,Residual CNN,Deep dilated residual CNN' --similarity --ylabel "Pearson R peak level" --plot_distribution --print_mean --savefig Modelcomparison_peakpearson


python3 ${codedir}scatter_comparison_plot.py $replica ${deep}_gene_corr_tcl0.txt "Replicate correlation adj. p-value (n=100)" "Prediction correlation peak level" --similarityB --logdensity --lw 0 --size 10 --cmap copper --savefig Replicatecorrvspredictioncorr

python3 ${codedir}scatter_comparison_plot.py ${deep}_gene_corr_tcl0.txt ${deepmouse}_gene_corr_tcl0.txt 'Deep dilated res. CNN' 'Deep dil. res. CNN (mouse trans.)' --zeroxaxis --zeroyaxis --plotdiagonal --logdensity --contour --similarityA --similarityB --lw 0 --savefig Deepdilres_mouseinit-vsrandom

deeplift=TestseqAttribfromATACcountsonPeak400rcomp-cv10-1_Cormsek256l15FfGELUrcTvlCotasft101_dc5i1d1-2-4-8-16s1l7r1_tc4dNoned1s1r1l7mw3nfc3s512cbnoTfdo0.1tr1e-05SGD0.9bs64-F_deepliftall.npz
ism=TestseqAttribfromATACcountsonPeak400rcomp-cv10-1_Cormsek256l15FfGELUrcTvlCotasft101_dc5i1d1-2-4-8-16s1l7r1_tc4dNoned1s1r1l7mw3nfc3s512cbnoTfdo0.1tr1e-05SGD0.9bs64-F_ism.npz
inputseq=../hg19GSE118189_ATAC_counts.txt_w400_onehot-ACGT_alignleft.npz

python3 ${codedir}plot_acrosscells_attribution_maps.py $deeplift $inputseq chr7_28080944_28081577 2,3,6,7,17,18  --outname chr7_28080944_28081577_deeplift
python3 ${codedir}plot_acrosscells_attribution_maps.py $ism $inputseq ../hg19GSE118189_ATAC_counts.txt_w400_onehot-ACGT_alignleft.npz chr7_28080944_28081577 2,3,6,7,17,18  --outname chr7_28080944_28081577_ism



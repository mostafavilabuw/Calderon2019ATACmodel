# Download human data from here: https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE118189&format=file&file=GSE118189%5FATAC%5Fcounts%2Etxt%2Egz
# Download processed mouse ATAC data from here: https://github.com/smaslova/AI-TAC/ 
	# You will need the bed file and the processed count matrix: https://www.dropbox.com/s/r8drj2wxc07bt4j/ImmGenATAC1219.peak_matched.txt?dl=0 https://www.dropbox.com/s/7mmd4v760eux755/mouse_peak_heights.csv?dl=0

# Process raw count data
python utils/processdata.py GSE118189_ATAC_counts.txt.gz 400

# create set file
python utils/createsetfromstat.py GSE118189_ATAC_counts.txt.lnorm.qntlnorm.btwsetscorradjp.txt 3

# create bed file for mouse data
python utils/txt2bed.py ImmGenATAC1219.peak_matched.txt

# Download training sets from enformer paper
#https://www.nature.com/articles/s41592-021-01252-x
#https://console.cloud.google.com/storage/browser/basenji_barnyard/data
#Convert hg38 locations to hg19 with https://genome.ucsc.edu/cgi-bin/hgLiftOver
# Or find in /Data/data_mouse_sequences.bed
python utils/enformertest.py /Data/data_mouse_sequences.bed ImmGenATAC1219.peak_matched.bed
python utils/enformertest.py /Data/data_human_sequences.h19.bed GSE118189_ATAC_counts.txt_w400.bed 

# Alternatively, one can create leave-chromosome out test and validation sets
python utils/maketesttrainsetsfrombed.py GSE118189_ATAC_counts.txt_w400.bed

# download human and mouse genomes
mkdir mm10
cd mm10
for i in {1..19}
do
wget --timestamping 'ftp://hgdownload.cse.ucsc.edu/goldenPath/mm10/chromosomes/chr'${i}'.fa.gz' -O chr${i}.fa.gz
done
cd ..

mkdir hg19
cd hg19
for i in {1..22}
do
wget --timestamping 'ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/chr'${i}'.fa.gz' -O chr${i}.fa.gz
done
cd ..


drgdir=/loc/of/drg/scripts/

# Create fasta file from bed file
python ${drgdir}/DRG/Data_preprocessing/bed2fasta_fromgenome.py hg19/ GSE118189_ATAC_counts.txt_w400.bed
python ${drgdir}/DRG/Data/preprocessing/bed2fasta_fromgenome.py mm10/ ImmGenATAC1219.peak_matched.bed

# Generate one-hot encodings
python ${drgdir}/DRG/models/seqtofeature_beta.py hg19GSE118189_ATAC_counts.txt_w400.fasta
python ${drgdir}/DRG/models/seqtofeature_beta.py mm10ImmGenATAC1219.peak_matched.fasta

# make input names shorter
ln -s hg19GSE118189_ATAC_counts.txt_w400_onehot-ACGT_alignleft.npz Peak400.pnz
ln -s mm10ImmGenATAC1219.peak_matched_onehot-ACGT_alignleft.npz mouseATAC_seq400.npz
ln -s mouse_peak_heights.csv mouseATAC.csv
ln -s GSE118189_ATAC_counts.txt.qntlnorm.lg2.csv ATACcounts.csv







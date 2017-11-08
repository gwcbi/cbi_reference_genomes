#! /bin/bash

umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git

### Download from HISAT website ##########################################################
mkdir -p Archive && cd Archive

# H. sapiens, UCSC hg38
wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/hg38.tar.gz
mv hg38.tar.gz Homo_sapiens_HISAT2_hg38.tar.gz

# H. sapiens, UCSC hg38 and Refseq gene annotations referred to in the Nature Protocol paper
wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/hg38_tran.tar.gz
mv hg38_tran.tar.gz Homo_sapiens_HISAT2_hg38_tran.tar.gz

# H. sapiens, UCSC hg19
wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/hg19.tar.gz
mv hg19.tar.gz Homo_sapiens_HISAT2_hg19.tar.gz

# H. sapiens, GRCh38
wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/grch38.tar.gz
mv grch38.tar.gz Homo_sapiens_HISAT2_grch38.tar.gz

wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/grch38_snp.tar.gz
mv grch38_snp.tar.gz Homo_sapiens_HISAT2_grch38_snp.tar.gz

wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/grch38_tran.tar.gz
mv grch38_tran.tar.gz Homo_sapiens_HISAT2_grch38_tran.tar.gz

wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/grch38_snp_tran.tar.gz
mv grch38_snp_tran.tar.gz Homo_sapiens_HISAT2_grch38_snp_tran.tar.gz

cd ..

### Unzip archives #######################################################################

mkdir -p References/Homo_sapiens/HISAT2 && cd References/Homo_sapiens/HISAT2

#--- hg38
mkdir -p hg38/Sequence && cd hg38/Sequence

tar xzf /groups/cbi/shared/References/cbi_reference_genomes.git/Archive/Homo_sapiens_HISAT2_hg38.tar.gz
mv hg38 Hisat2Index

tar xzf /groups/cbi/shared/References/cbi_reference_genomes.git/Archive/Homo_sapiens_HISAT2_hg38_tran.tar.gz
mv hg38_tran/* Hisat2Index
rmdir hg38_tran

cd ../..

#--- hg19
mkdir -p hg19/Sequence && cd hg19/Sequence

tar xzf /groups/cbi/shared/References/cbi_reference_genomes.git/Archive/Homo_sapiens_HISAT2_hg19.tar.gz
mv hg19 Hisat2Index

cd ../..

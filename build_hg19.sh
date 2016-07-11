#! /bin/bash

umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git

### Download iGenomes ####################################################################
mkdir -p Archive && cd Archive
wget ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/Homo_sapiens/UCSC/hg19/Homo_sapiens_UCSC_hg19.tar.gz
cd ..

### Extract iGenome ######################################################################
cat <<EOF
#! /bin/bash
umask 0002
module load pigz
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
tar --use-compress-program=pigz -xf ../Archive/Homo_sapiens_UCSC_hg19.tar.gz

EOF

### Build tophat references ##############################################################
sbatch -N 1 -t 2880 -p short <<EOF
#! /bin/bash
umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
cd Homo_sapiens/UCSC/hg19/Annotation

module load tophat/2.0.12
mkdir -p Tophat2Index
tophat2 -G Genes/genes.gtf --transcriptome-index Tophat2Index ../Sequence/Bowtie2Index/genome

EOF

### HISAT setup ##########################################################################
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References/Homo_sapiens/UCSC/hg19/Sequence
mkdir -p Hisat2Index && cd Hisat2Index
[[ ! -e genome.fa ]] && ln -s ../WholeGenomeFasta/genome.fa
[[ ! -e genes.gtf ]] && ln -s ../../Annotation/Genes/genes.gtf
cd ../../Annotation/Variation
rsync -a -P rsync://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/snp144Common.txt.gz .
cd ../../Sequence/Hisat2Index
[[ ! -e snp144Common.txt.gz ]] && ln -s ../../Annotation/Variation/snp144Common.txt.gz

module load hisat
hisat2_extract_snps_haplotypes_UCSC.py genome.fa snp144Common.txt.gz snp144
hisat2_extract_splice_sites.py genes.gtf > genes.splice
hisat2_extract_exons.py genes.gtf > genes.exon

### Build HISAT genome ###################################################################
sbatch -N 1 -t 2880 -p short <<EOF
#! /bin/bash
umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
cd Homo_sapiens/UCSC/hg19/Sequence/Hisat2Index

module load hisat/2.0.4
hisat2-build genome.fa genome
EOF

### Build HISAT genome_snp_tran ##########################################################
sbatch -N 1 -t 2880 -p 2tb <<EOF
#! /bin/bash
umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
cd Homo_sapiens/UCSC/hg19/Sequence/Hisat2Index

module load hisat/2.0.4
hisat2-build --snp snp144.snp --haplotype snp144.haplotype --ss genes.splice --exon genes.exon genome.fa genome_snp_tran
EOF

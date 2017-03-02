#! /bin/bash

umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git

### Download iGenomes ####################################################################
mkdir -p Archive && cd Archive
wget ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/Mus_musculus/Ensembl/GRCm38/Mus_musculus_Ensembl_GRCm38.tar.gz
cd ..

### Extract iGenome ######################################################################
sbatch -N 1 -p short -t 120 <<EOF
#! /bin/bash
umask 0002
module load pigz
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
tar --use-compress-program=pigz -xf ../Archive/Mus_musculus_Ensembl_GRCm38.tar.gz

EOF

### Build tophat references ##############################################################
sbatch -N 1 -t 2880 -p short <<EOF
#! /bin/bash
umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
cd Mus_musculus/Ensembl/GRCm38/Annotation

module load tophat/2.0.12
mkdir -p Tophat2Index
tophat2 -G Genes/genes.gtf --transcriptome-index Tophat2Index ../Sequence/Bowtie2Index/genome

EOF

### HISAT setup ##########################################################################
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References/Mus_musculus/Ensembl/GRCm38/Sequence
mkdir -p Hisat2Index && cd Hisat2Index
[[ ! -e genome.fa ]] && ln -s ../WholeGenomeFasta/genome.fa
[[ ! -e genes.gtf ]] && ln -s ../../Annotation/Genes/genes.gtf
[[ ! -e Mus_musculus.vcf ]] && ln -s ../../Annotation/Variation/Mus_musculus.vcf

#
#cd ../../Annotation
#mkdir -p Variation && cd Variation
#rsync -a -P rsync://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/snp144Common.txt.gz  .
#cd ../../Sequence/Hisat2Index
#[[ ! -e snp144Common.txt.gz ]] && ln -s ../../Annotation/Variation/snp144Common.txt.gz

module load hisat2
hisat2_extract_snps_haplotypes_VCF.py genome.fa Mus_musculus.vcf snp142
hisat2_extract_splice_sites.py genes.gtf > genes.splice
hisat2_extract_exons.py genes.gtf > genes.exon


### Build HISAT genome ###################################################################
sbatch -N 1 -t 2880 -p short <<EOF
#! /bin/bash
umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
cd Mus_musculus/Ensembl/GRCm38/Sequence/Hisat2Index

module load hisat2/2.0.4
hisat2-build genome.fa genome
EOF

### Build HISAT genome_snp_tran ##########################################################
sbatch -N 1 -t 2880 -p 2tb <<EOF
#! /bin/bash
umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
cd Mus_musculus/Ensembl/GRCm38/Sequence/Hisat2Index

module load hisat2/2.0.4
hisat2-build --snp snp142.snp --haplotype snp142.haplotype --ss genes.splice --exon genes.exon genome.fa genome_snp_tran
EOF

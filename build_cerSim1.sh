#! /bin/bash

umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git

### Download reference sequence from UCSC goldenPath #####################################
mkdir -p Archive && cd Archive
rsync -a -P rsync://hgdownload.cse.ucsc.edu/goldenPath/cerSim1/bigZips/cerSim1.fa.gz ./
cd ..

### Create assembly directory ############################################################
mkdir -p References/Ceratotherium_simum/UCSC/cerSim1

### Create Sequence subdirectory #########################################################
mkdir -p References/Ceratotherium_simum/UCSC/cerSim1/Sequence

### Create Sequence/WholeGenomeFasta subdirectory ########################################
mkdir -p References/Ceratotherium_simum/UCSC/cerSim1/Sequence/WholeGenomeFasta

### Unzip reference sequence #############################################################
unpigz -p 8 -c Archive/cerSim1.fa.gz > References/Ceratotherium_simum/UCSC/cerSim1/Sequence/WholeGenomeFasta/genome.fa

### Create Sequence/Bowtie2Index subdirectory ############################################
mkdir -p References/Ceratotherium_simum/UCSC/cerSim1/Sequence/Bowtie2Index

### Build Bowtie2 index ##################################################################
sbatch -N 1 -t 480 -p short <<EOF
#! /bin/bash
umask 0002
module load bowtie2/2.2.3
cd References/Ceratotherium_simum/UCSC/cerSim1/Sequence/Bowtie2Index
[[ ! -e genome.fa ]] && ln -s ../WholeGenomeFasta/genome.fa
bowtie2-build genome.fa genome

EOF

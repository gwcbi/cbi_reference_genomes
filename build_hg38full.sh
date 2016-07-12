#! /bin/bash

# This builds an hg38 reference with all human sequences from the UCSC analysis set

umask 0002
cd /groups/cbi/shared/References/REFCOPY

### Get the hg38 AnalysisSet bigZips from UCSC ###########################################
mkdir -p Archive && cd Archive

# Download the files
rsync -azvP rsync://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/analysisSet/hg38.fullAnalysisSet.chroms.tar.gz .
rsync -azvP rsync://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/analysisSet/md5sum.txt .

# Check the md5sums
grep 'hg38.fullAnalysisSet.chroms.tar.gz' md5sum.txt | md5sum -c -
rm md5sum.txt
cd ..

### Create directory structure ###########################################################
cd References
mkdir -p Homo_sapiens/UCSC/hg38full && cd Homo_sapiens/UCSC/hg38full
mkdir -p Annotation
mkdir -p Sequence

### Unzip the chromosomes ################################################################
cd Sequence
tar xzf /groups/cbi/shared/References/REFCOPY/Archive/hg38.fullAnalysisSet.chroms.tar.gz .
mv hg38.fullAnalysisSet.chroms Chromosomes

### Count the length of each chromosome/contig ###########################################
function fastaCount() {
    local infile=$1
    local nchar=$(grep -v '^>' $infile | tr -d '\n\r' | wc -c)
    echo -e "$infile\t$nchar"
}

for f in Chromosomes/*.fa; do fastaCount $f; done | sed 's|^Chromosomes/||' > tmp.sizes

### Sort the chromosome sizes file #######################################################
python <<EOF
from collections import defaultdict

lines = [l.strip('\n').split('\t') for l in open('tmp.sizes','r')]
chroms = defaultdict(list)
for l in lines:
    n = l[0].split('.')[0]
    chroms[n.split('_')[0]].append( (n,int(l[1])) )

sortedchroms = []
altchroms = []
randchroms = []
# The core 22 chromosomes, plus chrX, chrY, and chrM
corechroms = ['chr%d' % n for n in range(1,23)] + ['chrX','chrY', 'chrM']
for k in corechroms:
    sortedchroms.extend([c for c in chroms[k] if c[0]==k])
    altchroms.extend( sorted([c for c in chroms[k] if c[0].split('_')[-1]=='alt'], key=lambda x:int(x[1]), reverse=True))
    randchroms.extend( sorted([c for c in chroms[k] if c[0].split('_')[-1]=='random'], key=lambda x:int(x[1]), reverse=True))

sortedchroms = sortedchroms + altchroms + randchroms
sortedchroms.extend(sorted([c for c in chroms['chrUn']], key=lambda x:int(x[1]), reverse=True))
sortedchroms.extend(chroms['chrEBV'])

with open('hg38full.chrom.sizes','w') as outh:
    print >>outh, '\n'.join('%s\t%d' % t for t in sortedchroms)

EOF

rm tmp.sizes

### Make full genome fasta ###############################################################
mkdir -p WholeGenomeFasta
rm -f WholeGenomeFasta/genome.fa
cut -f1 hg38full.chrom.sizes | while read chr; do
    echo $chr
    cat Chromosomes/$chr.fa >> WholeGenomeFasta/genome.fa
done

### Sanity check: Check that sizes are equal #############################################
len1=$(fastaCount WholeGenomeFasta/genome.fa | cut -f2)
len2=$(cut -f2 hg38full.chrom.sizes | awk '{ sum += $1 } END { print sum }')
[[ $len1 == $len2 ]] && echo "Length is $len1" || echo "ERROR"

### Create genome indexes (samtools, picard) #############################################
cd WholeGenomeFasta
module load samtools
samtools faidx genome.fa
module load picard
picard CreateSequenceDictionary R=genome.fa O=genome.dict
cd ..
rm hg38full.chrom.sizes # Replaced by WholeGenomeFasta/genome.fa.fai

### Create bowtie2 index #################################################################
mkdir -p Bowtie2Index && cd Bowtie2Index
ln -s ../WholeGenomeFasta/genome.fa

sbatch -t 2880 -p short -N 1 <<EOF
#! /bin/bash
module load bowtie2
bowtie2-build genome.fa genome

EOF
cd ..

### Download blat index ##################################################################
mkdir -p Blat && cd Blat
rsync -azvP rsync://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/analysisSet/hg38.fullAnalysisSet.2bit .
rsync -azvP rsync://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/analysisSet/md5sum.txt .
grep 'hg38.fullAnalysisSet.2bit' md5sum.txt | md5sum -c -
rm md5sum.txt
cd ..

cd ..


### Get annotation data ##################################################################
mkdir -p Annotation/Genes && cd Annotation/Genes

# Cytogenic band information
mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -D hg38 -e "select chrom,chromStart,chromEnd,name,gieStain from cytoBand;" > cytoBand.txt

# Download refGene reference annotations from UCSC
module load ucsc
# genePred format
mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -D hg38 -e "select * from refGene;" > refGene.gpred
# Convert genePred to GTF
tail -n+2 refGene.gpred | cut -f 2- | genePredToGtf -source=refGene file stdin refGene.gtf

# Add tss_id and p_id to GTF
python /groups/cbi/shared/References/cbi_reference_genomes.git/scripts/add_tss_id_hg38full.py > tmp.gtf
python /groups/cbi/shared/References/cbi_reference_genomes.git/scripts/sortgtf.py --sortfile ../../Sequence/WholeGenomeFasta/genome.fa.fai < tmp.gtf > refGene.tss.gtf
rm tmp.gtf
ln -s refGene.tss.gtf genes.gtf 


### Build tophat references ##############################################################
sbatch -N 1 -t 2880 -p short <<EOF
#! /bin/bash
umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
cd Homo_sapiens/UCSC/hg38full/Annotation

module load tophat/2.0.12
mkdir -p Tophat2Index
tophat2 -G Genes/genes.gtf --transcriptome-index Tophat2Index ../Sequence/Bowtie2Index/genome

EOF

### HISAT setup ##########################################################################
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References/Homo_sapiens/UCSC/hg38full/Sequence
mkdir -p Hisat2Index && cd Hisat2Index
[[ ! -e genome.fa ]] && ln -s ../WholeGenomeFasta/genome.fa
[[ ! -e genes.gtf ]] && ln -s ../../Annotation/Genes/genes.gtf
cd ../../Annotation
mkdir -p Variation && cd Variation
rsync -a -P rsync://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/snp144Common.txt.gz  .
cd ../../Sequence/Hisat2Index
[[ ! -e snp144Common.txt.gz ]] && ln -s ../../Annotation/Variation/snp144Common.txt.gz

module load hisat2
hisat2_extract_snps_haplotypes_UCSC.py genome.fa snp144Common.txt.gz snp144
hisat2_extract_splice_sites.py genes.gtf > genes.splice
hisat2_extract_exons.py genes.gtf > genes.exon

### Build HISAT genome ###################################################################
sbatch -N 1 -t 2880 -p short <<EOF
#! /bin/bash
umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
cd Homo_sapiens/UCSC/hg38full/Sequence/Hisat2Index

module load hisat2/2.0.4
hisat2-build genome.fa genome
EOF

### Build HISAT genome_snp_tran ##########################################################
sbatch -N 1 -t 2880 -p 2tb <<EOF
#! /bin/bash
umask 0002
cd /groups/cbi/shared/References/cbi_reference_genomes.git/References
cd Homo_sapiens/UCSC/hg38full/Sequence/Hisat2Index

module load hisat2/2.0.4
hisat2-build --snp snp144.snp --haplotype snp144.haplotype --ss genes.splice --exon genes.exon genome.fa genome_snp_tran
EOF

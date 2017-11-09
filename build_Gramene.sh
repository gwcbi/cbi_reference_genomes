#! /bin/bash

#--- Download all the genomes from FTP
mkdir -p Archive/Gramene && cd Archive/Gramene
# First parse the directory listing to get available species
curl -s ftp://ftp.gramene.org/pub/gramene/release-55/fasta/ | tr -s ' ' | cut -f9 -d' ' > SPECIES.txt
# Now download the toplevel DNA file for each
cat SPECIES.txt | while read sp; do
    echo $sp
    wget ftp://ftp.gramene.org/pub/gramene/release-55/fasta/${sp}/dna/*.dna.toplevel.fa.gz
done

# Here is a list of all the species names with their taxonomy ID numbers:
spti=$(echo "Aegilops_tauschii 37682
Amborella_trichopoda 13333
Arabidopsis_lyrata 59689
Arabidopsis_thaliana 3702
Beta_vulgaris 161934
Brachypodium_distachyon 15368
Brassica_napus 3708
Brassica_oleracea 3712
Brassica_rapa 3711
Chlamydomonas_reinhardtii 3055
Chondrus_crispus 2769
Corchorus_capsularis 210143
Cyanidioschyzon_merolae 45157
Galdieria_sulphuraria 130081
Glycine_max 3847
Hordeum_vulgare 4513
Leersia_perrieri 77586
Medicago_truncatula 3880
Musa_acuminata 4641
Oryza_barthii 65489
Oryza_brachyantha 4533
Oryza_glaberrima 4538
Oryza_glumaepatula 40148
Oryza_indica 39946
Oryza_longistaminata 4528
Oryza_meridionalis 40149
Oryza_nivara 4536
Oryza_punctata 4537
Oryza_rufipogon 4529
Oryza_sativa 4530
Ostreococcus_lucimarinus 242159
Physcomitrella_patens 3218
Populus_trichocarpa 3694
Prunus_persica 3760
Selaginella_moellendorffii 88036
Setaria_italica 4555
Solanum_lycopersicum 4081
Solanum_tuberosum 4113
Sorghum_bicolor 4558
Theobroma_cacao 3641
Trifolium_pratense 57577
Triticum_aestivum 4565
Triticum_urartu 4572
Vitis_vinifera 29760
Zea_mays 4577
")

for p in Archive/Gramene/*.fa.gz; do
    fn=$(basename $p)
    sp=${fn%%.*}
    bd=$(sed 's/.dna.toplevel.fa.gz//' <<<${fn#*.})
    ti=$(grep "$sp" <<<"$spti" | cut -d' ' -f2)
    echo "species: $sp  ti: $ti"
    dest="References/$sp/Gramene/$bd/Sequence"
    sbatch -N 1 -t 300 -p short,defq  <<EOF
#! /bin/bash
umask 0002
mkdir -p $dest/WholeGenomeFasta
mkdir -p $dest/Bowtie2Index
unpigz -c $p | sed "s/^>/>ti|$ti|sp|$sp|bd|$bd|ref|/" > $dest/WholeGenomeFasta/genome_ti.fa
ln -s ../WholeGenomeFasta/genome_ti.fa $dest/Bowtie2Index/genome.fa
module load bowtie2/2.2.3
bowtie2-build $dest/Bowtie2Index/genome.fa $dest/Bowtie2Index/genome
EOF

done


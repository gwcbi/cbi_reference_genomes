# cbi_reference_genomes


## Available References

| Species       | Source        | Build     | Contigs/Chromosomes | TopHat   | HiSat   | Notes | 
| ------------- |:-------------:| -----:    | ---- |---      | ---     | ---   |
| *Homo sapiens*| UCSC          | hg19      | 25   | &#10003; | &#10003;|[iGenomes](http://support.illumina.com/sequencing/sequencing_software/igenome.html)    |
|               |               | hg38      | 195  | &#10003; | &#10003;| Includes extra-chromosomal contigs, no alternate haplotypes. [iGenomes](http://support.illumina.com/sequencing/sequencing_software/igenome.html)     |
|               |               | hg38full  | 456  | &#10003; | &#10003; | Includes extra-chromosomal contigs and alternate haplotypes (261 sequences) |
| *Ceratotherium simum* (white rhino) | UCSC | cerSim1| 3087 | | | |
| *Mus musculus* | Ensembl | GRCm38 | 22 | &#10003; | &#10003; | [iGenomes](http://support.illumina.com/sequencing/sequencing_software/igenome.html)     |

## Building References

Scripts for building reference genomes. See `build_xx.sh`

## Directory Structure


### `References/`

This directory contain the reference genome sequences, indexes, and annotations. The goal is for the contents of this directory to be kept in sync with `/lustre/groups/cbi/shared/References`. The following directory structure is used: `References/[Species]/[Source]/[Build]`.

Each build has the following nested directory structure:

`Sequence/`
`Annotation/`


### `Archive/`

### `scripts/`


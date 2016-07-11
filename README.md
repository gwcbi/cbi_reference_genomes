# cbi_reference_genomes


## Available References

| Species       | Source        | Build  | TopHat   | HiSat   | Notes | 
| ------------- |:-------------:| -----: | ---      | ---     | ---   |
| *Homo sapiens*| UCSC          | hg19   | &#10003; | &#10003;|[iGenomes](http://support.illumina.com/sequencing/sequencing_software/igenome.html)    |
|               |               | hg38   | &#10003; | &#10003;| [iGenomes](http://support.illumina.com/sequencing/sequencing_software/igenome.html)     |
|               |               | hg38full |        |         | Includes haplotypes and extra-chromosomal contigs
| *Ceratotherium simum* (white rhino) | UCSC      |    cerSim1| |

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


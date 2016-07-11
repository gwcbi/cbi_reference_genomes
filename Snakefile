
WGET_COMMAND = 'wget'

rule hg19_extract:
    input: 'Archive/Homo_sapiens_UCSC_hg19.tar.gz'
    output:
    shell:

rule hg19_download:
    output: 'Archive/Homo_sapiens_UCSC_hg19.tar.gz'
    shell:
        '''{WGET_COMMAND} ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/Homo_sapiens/UCSC/hg19/Homo_sapiens_UCSC_hg19.tar.gz'''

rule hg38_download:
    output: 'Archive/Homo_sapiens_UCSC_hg38.tar.gz'
    shell:
        '''{WGET_COMMAND} ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/Homo_sapiens/UCSC/hg38/Homo_sapiens_UCSC_hg38.tar.gz'''

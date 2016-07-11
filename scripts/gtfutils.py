#! /usr/bin/env python

import re
from collections import defaultdict

class GTFRecord:
    attribute_order = ['gene_id', 'transcript_id',
                       'gene_type', 'gene_status', 'gene_name',
                       'transcript_type', 'transcript_status', 'transcript_name',
                       'exon_number', 'exon_id', 'level',
                       'tss_id', 'p_id', ]
    def __init__(self,fields):
        self.chrom   = fields[0]
        self.source  = fields[1]
        self.feature = fields[2]
        self.spos    = int(fields[3])
        self.epos    = int(fields[4])
        self.score   = fields[5]
        self.strand  = fields[6]
        self.frame   = fields[7]
        self.attrs = dict(re.findall('(\S+)\s+"([\s\S]+?)";',fields[8]))
    
    def attr_field(self):
        _attrkeys = [k for k in self.attribute_order if k in self.attrs] + sorted([k for k in self.attrs.keys() if k not in self.attribute_order])
        return '; '.join('%s "%s"' % (k,self.attrs[k]) for k in _attrkeys) + ';'
    
    def __str__(self):
        return '\t'.join([self.chrom, self.source, self.feature, 
                          str(self.spos), str(self.epos), self.score, self.strand,
                          self.frame, self.attr_field()])

def gtf_bygroup(gtfrecords, key):
    by_key = defaultdict(list)
    for g in gtfrecords:
        by_key[ g.attrs[key] ].append(g)
    return by_key

def sortgtf(gtfrecords, chromsort=None):
    # gtfrecords is a list of GTFRecord objects
    # chromsort is a list with chromosome names in the desired sort order
    # If chromsort is not provided, chromosomes are sorted as strings
    gtfrecords.sort(key=lambda x:x.spos)
    if chromsort is None:
        gtfrecords.sort(key=lambda x: x.chrom)
    else:
        gtfrecords.sort(key=lambda x: chromsort.index(x.chrom))

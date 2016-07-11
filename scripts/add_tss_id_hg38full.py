#! /usr/bin/env python

import sys
from gtfutils import GTFRecord, gtf_bygroup
from collections import Counter

#--- Check that we can get the correct transcript IDs
# genePredToGtf assigns transcript IDs from the "name" column of the genePred file.
# Some IDs are repeated (same ID refers to distinct transcripts). When this happens,
# the count is appended to the transcript ID, for example, the second transcript with
# NR_XXXXXX as the ID will be called NR_XXXXXX_2, the third NR_XXXXXX_3, and so on.
# This is in the same order as the genePred file.
print >>sys.stderr, 'Checking that transcript IDs can be generated from genePred...'
_lines = (l.strip('\n').split('\t') for l in open('refGene.gtf','r') if not l.startswith('#'))
_gtf = [GTFRecord(l) for l in _lines]
_bytxid = gtf_bygroup(_gtf, 'transcript_id')

_gp = (l.strip().split('\t') for l in open('refGene.gpred','r'))
_header = _gp.next()

_transcript_counter = Counter()
for _gpr in _gp:
    #--- Calculate the transcript ID
    _transcript_counter[_gpr[1]] += 1
    _transcript_id = _gpr[1] if _transcript_counter[_gpr[1]]==1 else '%s_%d' % (_gpr[1], _transcript_counter[_gpr[1]])
    assert _transcript_id in _bytxid, '%s not in GTF file' % _transcript_id
    _exons = sorted(_bytxid[_transcript_id], key=lambda x:int(x.attrs['exon_number']))
    assert _exons[0].spos == int(_gpr[4]) + 1

print >>sys.stderr, 'Transcript IDs are OK'
print >>sys.stderr, 'Assigning tss_id and p_id...'

transcript_counter = Counter()
tsskey_tssid = {}
transcript_tsskey = {}
pkey_pid = {}
transcript_pkey = {}

gp = (l.strip().split('\t') for l in open('refGene.gpred','r'))
header = gp.next()

for gpr in gp:
    #--- Calculate the transcript ID
    transcript_counter[gpr[1]] += 1
    transcript_id = gpr[1] if transcript_counter[gpr[1]]==1 else '%s_%d' % (gpr[1], transcript_counter[gpr[1]])
    
    #--- Assign TSS ID for transcript
    # First generate a key string that identifies the TSS, then assign a tss_id to that
    # key string. Subsequent genes with the same TSS will generate the same key string and
    # will thus be assigned the same tss_id
    if gpr[3] == '+':
        tsskey = '%s|%s|%s' % (gpr[2], gpr[3], gpr[4])
    else:
        assert gpr[3] == '-'
        tsskey = '%s|%s|%s' % (gpr[2], gpr[3], gpr[5])
    if tsskey not in tsskey_tssid:
        tsskey_tssid[tsskey] = 'TSS%d' % (len(tsskey_tssid)+1)
    # Now map the transcript ID to the tsskey, which maps to the tss_id
    transcript_tsskey[transcript_id] = tsskey
    
    #--- Assign Protein ID for transcript
    # Skip over genes with no CDS. First generate a key string that identifies the protein,
    # then assign a p_id.
    if gpr[6] == gpr[7]:
        pass # Non-coding
    else:
        pkey = '%s|%s|%s|%s|%s|%s' % (gpr[2], gpr[3], gpr[6], gpr[7], gpr[9], gpr[10])
        if pkey not in pkey_pid:
            pkey_pid[pkey] = 'P%d' % (len(pkey_pid)+1)
        # Now map the transcript ID to the pkey, which maps to the p_id
        transcript_pkey[transcript_id] = pkey

# Reload the GTF file
lines = (l.strip('\n').split('\t') for l in open('refGene.gtf','r') if not l.startswith('#'))
gtf = (GTFRecord(l) for l in lines)

for g in gtf:
    assert g.attrs['transcript_id'] in transcript_tsskey, 'ERROR: %s not found in transcript ids' % g.attrs['transcript_id']
    tsskey = transcript_tsskey[g.attrs['transcript_id']]
    assert tsskey in tsskey_tssid, 'ERROR: %s not found in keys' % tsskey
    g.attrs['tss_id'] = tsskey_tssid[tsskey]
    if g.attrs['transcript_id'] in transcript_pkey:
        pkey = transcript_pkey[g.attrs['transcript_id']]
        assert pkey in pkey_pid, 'ERROR: %s not found in keys' % pkey
        g.attrs['p_id'] = pkey_pid[pkey]
    print >>sys.stdout, str(g)

print >>sys.stderr, 'Complete.'

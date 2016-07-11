#! /usr/bin/env python
import sys
import os
from glob import glob
import subprocess

"""
spath = './References'
build_paths = sorted(glob(os.path.join(spath, '*/*/*')))


# reference_dest = "/lustre/groups/cbi/shared/References"
build_paths = sorted(glob('References/*/*/*'))
builds = {p.split('/')[-1]:p for p in build_paths}

print >>sys.stderr, "Genomes available for sync:"
print >>sys.stderr, "Species".ljust(30) + "Source".ljust(20) + "Build".ljust(20)
for bp in build_paths:
    refdir,species,source,build = bp.split('/')
    print >>sys.stderr, '%s%s%s' % (species.ljust(30), source.ljust(25), build.ljust(25))

response = raw_input("Enter build name to sync: ")
if response in builds:
    
else:
    print >>sys.stderr, 'Error, build "%s" is not available.' % response

# rsync -av References/Homo_sapiens/UCSC/hg19 /lustre/groups/cbi/shared/References/Homo_sapiens/UCSC
# rsync -av References/Homo_sapiens/UCSC/hg19 /lustre/groups/cbi/shared/References/Homo_sapiens/UCSC
"""

def main(args):
    build_paths = sorted(glob(os.path.join(args.source_path, '*/*/*')))
    if len(build_paths) == 0:
        sys.exit('No references found')
        
    bdata = {}
    for bp in build_paths:
        pre,build = os.path.split(bp)
        pre,source = os.path.split(pre)
        pre,species = os.path.split(pre)
        bdata[build] = {'path':bp, 'prefix':pre, 'source':source, 'species':species, 'build':build}    

    if args.build is None:
        print >>sys.stderr, "Genomes available for sync:"
        print >>sys.stderr,  "Build".ljust(16) + "Species".ljust(29) + "Source".ljust(16) + "Prefix"
        print >>sys.stderr,  ''.join(['-'] * 80)
        for b in sorted(bdata.keys()):
            print >>sys.stderr, '%s%s%s%s' % (bdata[b]['build'].ljust(16), bdata[b]['species'].ljust(32), bdata[b]['source'].ljust(16), bdata[b]['prefix'])
        print >>sys.stderr,  ''.join(['-'] * 80)            
        id = raw_input("Enter build name to sync: ")
    else:
        id = args.build

    if id in bdata:
        build_source = bdata[id]['path']
        build_dest   = os.path.join( os.path.join(args.dest_path, bdata[id]['species']), bdata[id]['source'] )
        print >>sys.stdout, 'Rsync command:\nrsync -av %s %s' % (build_source, build_dest)
        if not args.dry_run:
            subprocess.check_output(["rsync", "-av", build_source, build_dest])
    elif id == 'ALL':
        for bid in bdata.keys():
            build_source = bdata[bid]['path']
            build_dest   = os.path.join( os.path.join(args.dest_path, bdata[bid]['species']), bdata[bid]['source'] )
            print >>sys.stdout, 'Rsync command:\nrsync -av %s %s' % (build_source, build_dest)
            if not args.dry_run:
                subprocess.check_output(["rsync", "-av", build_source, build_dest])            
    else:
        sys.exit('Error, build "%s" is not available.' % id)

if __name__ == '__main__':                
    import argparse
    parser = argparse.ArgumentParser(description='Synchronize references between directories.')
    parser.add_argument('--dry_run', action="store_true",
                        help='Print out commands, do not call rsync')
    parser.add_argument('--dest_path', default="/lustre/groups/cbi/shared/References",
                        help='Destination directory')
    parser.add_argument('--source_path', default="./References",
                        help='Source directory')
    parser.add_argument('build', nargs='?', default=None,
                        help='Reference build name to be synchronized')
    main(parser.parse_args())

import numpy as np
import sys, os

def read(f, namefirst = False):
    lines = open(f,'r').readlines()
    chrs, loc, names = [],[],[]
    ni, sh = 3,0
    if namefirst:
        ni = 0
        sh = 1
    for l, line in enumerate(lines):
        line = line.strip().split('\t')
        chrs.append(line[0+sh])
        loc.append([line[1+sh], line[2+sh]])
        names.append(line[ni])
    loc = np.array(loc, dtype = int)
    chrs = np.array(chrs)
    names = np.array(names)
    return names, chrs, loc

enfregions=sys.argv[1] #'../EnformerData/data_mouse_sequences.bed' #'../EnformerData/data_human_sequences.h19.bed'
etypes, echrs, elocs = read(enfregions)
transreg = sys.argv[2]
tnames, tchrs, tlocs = read(transreg, namefirst = False)


train, val, test = [],[],[]
for c, ch in enumerate(tchrs):
    if c %10000 == 0:
        print(c, ch)
    loc = tlocs[c]
    mask = np.where(echrs == ch)[0]
    islarger = elocs[mask,0] < loc[1]
    issmaller = elocs[mask,1] > loc[0]
    overlap = islarger * issmaller
    settype = mask[overlap]
    settype = etypes[settype]
    if 'train' in settype:
        train.append(tnames[c])
    elif 'test' in settype:
        test.append(tnames[c])
    elif 'valid' in settype:
        val.append(tnames[c])
    else:
        train.append(tnames[c])

print(len(train), len(val), len(test))
np.savez_compressed(os.path.splitext(transreg)[0]+'_enformer_testsets.npz', train = train, valid = val, test = test)
obj = open(os.path.splitext(transreg)[0]+'_enformer_testsets.txt', 'w')
obj.write('# Set_0'+'\n' + ' '.join(val)+'\n')
obj.write('# Set_1'+'\n' + ' '.join(test)+'\n')









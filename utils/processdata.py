import numpy as np
import sys, os
import gzip
import time 
import time
from scipy.stats import ttest_1samp
from statsmodels.stats.multitest import multipletests


inp = sys.argv[1]
blen = int(sys.argv[2])
wing = int(blen/2)
obj = gzip.open(inp, 'rt').readlines()

cell_types = np.array(obj[0].strip().split('\t'))

print('Total length of file', len(obj))

outname = os.path.splitext(inp)[0]

names = []
counts = []
t0 = time.time()
for l, line in enumerate(obj):
    if (l+1) % 100000 == 0:
        print(l, round(time.time() - t0 ,2))
    if l > 0:
        line = line.strip().split('\t')
        names.append(line[0])
        counts.append(line[1:])

print('writing')
#bobj = open(os.path.splitext(inp)[0]+'_w'+str(blen)+'.bed', 'w')
reglen = []
for n, name in enumerate(names):
    if (n+1) % 10000 == 0:
        print('bed', n)
    loc = name.split('_')
    center = int((int(loc[1])+int(loc[2]))/2)
    reglen.append(int(loc[2])-int(loc[1]))
    start, end = center-wing, center + wing + 1
 #   bobj.write(loc[0]+'\t'+str(start)+'\t'+str(end)+'\t'+name+'\n')


print('Peak lengths', np.mean(reglen), np.median(reglen), np.amin(reglen), np.amax(reglen), np.percentile(reglen, 95), np.percentile(reglen, 99))

counts = np.array(counts, dtype = float)
if '--normcounts' in sys.argv:
    counts = counts/np.array(reglen)[:,None]*1000
    outname += '.lnorm'

counts = np.log2(2+counts)
print('counts log transformed')
lcounts = np.copy(counts)

if '--fracnorm' in sys.argv:
    rowsum = np.sum(counts,axis = 1)
    colummedians = np.median(counts/rowsum[:,None], axis = 0)
    meanmedian = np.mean(colummedians)
    counts = (counts/colummedians)  * meanmedian
    print('counts median fracions normalized')
    outname += '.medfracnorm'
else:
    sortedmean = np.mean(np.sort(counts,axis = 0), axis =1)
    counts = sortedmean[np.argsort(np.argsort(counts,axis = 0),axis=0)]
    print('counts quantile normalized')
    outname += '.qntlnorm'

cells, donor = [], []
for c, ct in enumerate(cell_types):
    ct = ct.split('-',1)
    cells.append(ct[1])
    donor.append(ct[0])

cells = np.array(cells)
donor = np.array(donor)

ucells, ucn = np.unique(cells, return_counts = True)
print('Unique cells', len(ucells))
for u, uc in enumerate(ucells):
    print(uc, ucn[u])


def corrcoef(x,y):
    x, y = x-np.mean(x, axis = 1)[:,None], y-np.mean(y, axis = 1)[:,None]
    corr = np.sum(x*y, axis = 1)/(np.sqrt(np.sum(x**2, axis =1))*np.sqrt(np.sum(y**2, axis =1)))
    return corr

repcorrs = []
for i in range(100):
    perm = np.random.permutation(len(cells))
    ucells, ucind = np.unique(cells[perm], return_index = True)
    set1 = perm[ucind]
    nperm = np.setdiff1d(perm,set1)
    ucells, ucind = np.unique(cells[nperm], return_index = True)
    set2 = nperm[ucind]
    repcorrs.append(corrcoef(counts[:,set1], counts[:,set2]))
    if i%10 == 0:
        print(i)

repcorrs = np.array(repcorrs)
st_, pvalues = ttest_1samp(repcorrs, 0, axis = 0, alternative = 'greater')
istrue, adjp, s_, t_ = multipletests(pvalues, alpha = 0.001, method = 'fdr_bh')

minrepcorrs = np.amin(repcorrs, axis = 0)
repcorrs = np.mean(repcorrs,axis = 0)

np.savetxt(outname+'.btwsetscorrmin.txt', np.array([names, np.around(minrepcorrs,2)]).T.astype(str), fmt = '%s')
np.savetxt(outname+'.btwsetscorr.txt', np.array([names, np.around(repcorrs,2)]).T.astype(str), fmt = '%s')
np.savetxt(outname+'.btwsetscorradjp.txt', np.array([names, np.around(-np.log10(adjp),2)]).T.astype(str), fmt = '%s')

mcounts = np.zeros((len(counts), len(ucells)))
mlcounts = np.zeros((len(counts), len(ucells)))
for c, ct in enumerate(ucells):
    print(c, ct)
    mcounts[:,c] = np.mean(counts[:, cells == ct], axis = 1)
    mlcounts[:,c] = np.mean(lcounts[:, cells == ct], axis = 1)

counts = mcounts
lcounts = mlcounts

cell_types = ucells

counts = np.around(counts,3)
lcounts = np.around(lcounts,3)
print('counts rounded to 3 digits')



np.savetxt(outname+'.lg2.csv', np.append(np.array(names).reshape(-1,1), counts.astype(str), axis = 1), delimiter = ',', fmt = '%s', header = ','.join(cell_types))
np.savetxt(outname+'.orig.csv', np.append(np.array(names).reshape(-1,1), lcounts.astype(str), axis = 1), delimiter = ',', fmt = '%s', header = ','.join(cell_types))

if '--generate_untreated_set' in sys.argv:
    treat = np.array([b.rsplit('-',1)[1] for b in cell_types])
    utreat = treat == 'U'
    print('untreated', np.sum(utreat))
    np.savetxt(outname+'.lg2.U.csv', np.append(np.array(names).reshape(-1,1), counts.astype(str)[:,utreat], axis = 1), delimiter = ',', fmt = '%s', header = ','.join(cell_types[utreat]))




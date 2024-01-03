import numpy as np
import sys, os


def groupings(tlen, groupsizes):
    groups = []
    csize = []
    avail = np.arange(len(groupsizes), dtype = int)
    while True:
        if len(avail) < 1 or len(csize) == 10:
            break
        seed = np.random.choice(avail)
        group = np.array([seed])
        avail = avail[~np.isin(avail, group)]
        gdist = abs(tlen-np.sum(groupsizes[group]))
        while True:
            if len(avail) < 1:
                break
            ngr = avail.reshape(-1,1)
            egr = np.repeat(group, len(ngr)).reshape(len(group), len(ngr)).T
            pgr = np.append(egr, ngr, axis = 1)
            pdist = np.abs(tlen-np.sum(groupsizes[pgr],axis = 1))
            if (pdist < gdist).any():
                mgr = np.argmin(pdist)
                group = pgr[mgr]
                gdist = pdist[mgr]
                avail = avail[~np.isin(avail, group)]
            else:
                groups.append(group)
                csize.append(int(np.sum(groupsizes[group])))
                break
    return groups, np.array(csize), np.mean(np.abs(np.array(csize) - tlen))


def generatetesttrain(names, groups, outname):
    ugroups, ugroupsize = np.unique(groups, return_counts = True)
    #print(ugroups, ugroupsize)
    n = len(names)
    st = int(n/10)
    cdist = st
    for i in range(10000):
        cgroups, cgroupsizes, msize = groupings(st, ugroupsize)
        #print(cgroups, cgroupsizes, msize)
        if msize < cdist:
            combgroups = cgroups
            combsize = cgroupsizes
            cdist = np.copy(msize)
    print('Best split', cdist)

    obj=open(outname, 'w')
    for j, grp in enumerate(combgroups):
        print(j, ugroups[grp], np.sum(ugroupsize[grp]) - st)
        test = names[np.isin(groups, ugroups[grp])]
        obj.write('# Set_'+str(j)+'\n' + ' '.join(test)+'\n')


bed = np.genfromtxt(sys.argv[1], dtype = str)
outname = os.path.splitext(sys.argv[1])[0]+'_tset10.txt'

generatetesttrain(bed[:,3], bed[:,0], outname)



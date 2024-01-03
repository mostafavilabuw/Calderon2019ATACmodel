import numpy as np
import sys, os


f = sys.argv[1]
cut = sys.argv[2]

outname = os.path.splitext(f)[0] + '_gt'+cut+os.path.splitext(f)[1]

f = np.genfromtxt(f, dtype = str)
mask = f[:,1].astype(float) > float(cut)
print(cut, int(np.sum(mask)))
np.savetxt(outname, f[mask,0], fmt = '%s')


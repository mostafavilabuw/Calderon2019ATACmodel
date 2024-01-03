import numpy as np
import sys, os

txtfile = sys.argv[1]
a = np.genfromtxt(txtfile, dtype = str)
a = np.append(a[:,1:],a[:,[0]], axis = 1)
np.savetxt(os.path.splitext(txtfile)[0] + '.bed', a, delimiter = '\t', fmt = '%s')


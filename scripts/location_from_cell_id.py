#!/usr/bin/python

import sys, s2sphere

ll = s2sphere.CellId(int(sys.argv[1])).to_lat_lng()
sys.stdout.write(str(ll)[8:])

#!/bin/bash
import os
import sys
import subprocess

interface = sys.argv[1]
ap = sys.argv[2]

#os.system("airmon-ng check kill")

#os.system("airmon-ng start "+interface)

intmon = interface +"mon"

#out = subprocess.check_output("airodump-ng --encrypt opn -w aps" + intmon) #airodump-ng --encrypt opn -w aps $INTMON

ls = subprocess.check_output('ls')
#print(ls)

cm = "grep \'" + ap + "\' aps-01.csv | cut -d ' ' -f1 | cut -c '1-17'"
print(cm)
grepout = subprocess.check_output(cm)

print(grepout)








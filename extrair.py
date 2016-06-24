import os,sys
arquivo = open('0_EDGV_2_13_v.3_final.sql','r')
b = open('geomnotnull.sql','w')
for i in arquivo.readlines():
    if('ALTER COLUMN geom SET NOT NULL;' in i):
        b.write(i);
        
arquivo.close()
b.close()

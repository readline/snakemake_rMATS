#!/usr/bin/env python
import os,sys
import pandas as pd
from statistics import median

def samplesheet(sspath):
    df = pd.read_csv(sspath, sep='\t')
    
    # Initialize dictionaries
    sample_dic = {}  # Sample -> {Group, Readlen, Bam}
    group_dic = {}   # Group -> [Samples]
    combinations = {}   # {Group1.vs.Group2: (Group1, Group2), ...}]
    
    # Process each row
    for _, row in df.iterrows():
        # Create nested dict for sample_dic
        sample_dic[row['Sample']] = {
            'Group': row['Group'],
            'Readlen': row['Readlen'],
            'Bam': row['Bam']
        }
        
        # Add sample to group_dic
        if row['Group'] not in group_dic:
            group_dic[row['Group']] = []
        group_dic[row['Group']].append(row['Sample'])
    
    maxreadlen = df['Readlen'].max()
    
    # Create combinations
    for i in range(0, len(group_dic)):
        for j in range(i+1, len(group_dic)):
            group1 = list(group_dic.keys())[i]
            group2 = list(group_dic.keys())[j]
            combinations['%s.vs.%s'%(group1, group2)] = (group1, group2)
    return sample_dic, group_dic, maxreadlen, combinations

    

if __name__ == '__main__':
    for (i,j) in zip('sample_dic, group_dic, maxreadlen, combinations'.split(','), samplesheet(sys.argv[1])):
        print(i,j)

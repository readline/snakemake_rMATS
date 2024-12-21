#!/usr/bin/env python
import os,sys
import pandas as pd
from statistics import median

def samplesheet(sspath):
    df = pd.read_csv(sspath, sep='\t')
    
    # Initialize dictionaries
    sample_dic = {}  # Sample -> {Group, Readlen, Bam}
    group_dic = {}   # Group -> [Samples]
    
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
    return sample_dic, group_dic, maxreadlen

    

if __name__ == '__main__':
    for (i,j) in zip('sample_dic, group_dic, maxreadlen'.split(','), samplesheet(sys.argv[1])):
        print(i,j)

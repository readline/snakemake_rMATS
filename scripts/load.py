#!/usr/bin/env python
import os,sys
import pandas as pd
from statistics import median

def samplesheet(sspath):
    df = pd.read_csv(sspath, sep='\t')
    sample_dic, sample_dic_ = {},{}
    lb_dic, lb_dic_ = {},{}
    rg_dic = {}
    st_dic = {}
    rl_dic = {}
    sm2st, lb2st, rg2st = {},{},{}
    pu_dic = {}
    sm2rg_dic = {}
    for i in df.index:
        sm = str(df.loc[i,'SM'])
        lb = str(df.loc[i,'LB'])
        pu = str(df.loc[i,'PU'])
        rg = 'RG.%s.%s.%s'%(sm, lb, pu)
        sm = 'SM.%s'%(sm)
        lb = 'LB.%s'%(lb)
        pu = 'PU.%s'%(pu)
        st = str(df.loc[i,'ST'])
        r1 = str(df.loc[i,'R1'])
        r2 = str(df.loc[i,'R2'])
        rl = int(df.loc[i,'RL'])
        if sm not in sample_dic:
            sample_dic[sm] = []
            sm2rg_dic[sm] = []
        if lb not in lb_dic:
            lb_dic[lb] = []
        if lb not in sample_dic[sm]:
            sample_dic[sm].append(lb)
        if rg not in lb_dic[lb]:
            lb_dic[lb].append(rg)
            lb_dic_[rg] = lb
        if rg not in sm2rg_dic[sm]:
            sm2rg_dic[sm].append(rg)
        rg_dic[rg] = {'R1':r1, 'R2':r2}
        sample_dic_[rg] = sm
        pu_dic[rg] = pu
        sm2st[sm] = st
        lb2st[lb] = st
        rg2st[rg] = st
        rl_dic[rg] = rl
    return sample_dic, lb_dic, rg_dic, pu_dic, sm2st, lb2st, rg2st, rl_dic, lb_dic_, sample_dic_, sm2rg_dic

if __name__ == '__main__':
    for (i,j) in zip('sample_dic, lb_dic, rg_dic, pu_dic, sm2st, lb2st, rg2st, rl_dic, lb_dic_, sample_dic_, sm2rg_dic'.split(','), samplesheet(sys.argv[1])):
        print(i,j)

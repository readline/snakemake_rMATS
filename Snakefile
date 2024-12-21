import os,sys
import yaml
from os.path import join
import pandas as pd
from scripts.load import samplesheet
from scripts.utils import (allocated, ignore, stringtiestrand, gatkstrand)

# Load config file
configfile: 'config.yaml'
workdir: config['workdir']

pipedir = config['pipelinedir']
print(config)

# Load cluster config
with open(join(config['pipelinedir'], 'cluster.yaml')) as infile:
    cluster = yaml.safe_load(infile)

# Load sample sheet
sample_dic, lb_dic, rg_dic, pu_dic, sm2st, lb2st, rg2st, rl_dic, lb_dic_, sample_dic_, sm2rg_dic = \
samplesheet(join(config['pipelinedir'],'samplesheet.tsv'))
print(lb_dic)
# include rules
include: join(config['pipelinedir'], "rules", "example.smk")

rule all:
    input:
        expand(
            join(config['workdir'], "01.CleanData", "{sample}", "{sample}.QC.html"),
            sample=sample_dic,
        ),

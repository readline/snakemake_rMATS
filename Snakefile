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
sample_dic, group_dic, maxreadlen, combinations = samplesheet(join(config['pipelinedir'],'samplesheet.tsv'))
config['maxreadlen'] = maxreadlen
group_to_bam = {}
for g in group_dic:
    group_to_bam[g] = [sample_dic[s]['Bam'] for s in group_dic[g]]

# include rules
include: join(config['pipelinedir'], "rules", "rmats.smk")

rule all:
    input:
        expand(
            join(config['workdir'], "00.configs", "Group.{group}.txt"),
            group=group_dic,
        ),
        expand(
            join(config['workdir'], "01.rmats","{vs}","rmats.ok"),
            vs=combinations,
        )
        # expand(
        #     join(config['workdir'], "01.bam", "{sample}.bam.bai"),
        #     sample=sample_dic
        # )

rule CollectRnaSeqMetrics_SM:
    input:
        bam = join(config['workdir'], "02.STAR", "{sample}", "{sample}.sort.markdup.bam"),
    output:
        metrics = join(config['workdir'],"02.STAR","{sample}","QC","{sample}.CollectRnaSeqMetrics.metrics"),
    log:
        out = join(config['pipelinedir'], "logs", "CollectRnaSeqMetrics_SM", "{sample}.o"),
        err = join(config['pipelinedir'], "logs", "CollectRnaSeqMetrics_SM", "{sample}.e"),
    params:
        folder = directory(join(config['workdir'],"02.STAR","{sample}","QC")),
        st = gatkstrand(lambda wildcards: st_dic[wildcards.sample])
    threads:
        int(allocated("threads", "CollectRnaSeqMetrics_SM", cluster))
    container:
        config['container']['ctat_mutations']
    shell:
        '''cd {params.folder}
        gatk CollectRnaSeqMetrics \
          -I {input.bam} \
          -O {output.metrics} \
          --REF_FLAT {config[cachedir]}/{config[references][refflat][path]} \
          {params.st} >> {log.out} 2>> {log.err}
        '''

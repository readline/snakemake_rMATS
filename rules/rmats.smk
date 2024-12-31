rule prepare_bam_input:
    input:
        bam = lambda wildcards: sample_dic[wildcards.sample]['Bam']
    output:
        bam = join(config['workdir'], "00.bam", "{sample}.bam")
    params:
        folder = directory(join(config['workdir'],"00.bam")),
    threads:
        4
    container:
        config['container']['samtools']
    shell:
        "cd {params.folder} \n"
        "ln -s {input.bam} {output.bam} \n"
        "samtools index -@ {threads} {output.bam}"

rule prepare_rmats_config:
    input:
        lambda wildcards: ['{}/00.bam/{}.bam'.format(config['workdir'], s) for s in group_dic[wildcards.group]]
    output:
        join(config['workdir'], "00.configs", "Group.{group}.txt"),
    log:
        out = join(config['pipelinedir'], "logs", "prepare_rmats_config", "{group}.o"),
        err = join(config['pipelinedir'], "logs", "prepare_rmats_config", "{group}.e"),
    params:
        folder = directory(join(config['workdir'],"00.configs")),
    threads:
        1
    run:
        with open(output[0], 'w') as savefile:
            savefile.write(','.join(input)+'\n')

rule rmats:
    input:
        group0 = lambda wildcards: "{}/00.configs/Group.{}.txt".format(config['workdir'], combinations[wildcards.vs][0]),
        group1 = lambda wildcards: "{}/00.configs/Group.{}.txt".format(config['workdir'], combinations[wildcards.vs][1]),
    output:
        ok = join(config['workdir'], '01.rmats', '{vs}', 'rmats.ok'),
    log:
        out = join(config['pipelinedir'], "logs", "rmats", "{vs}.o"),
        err = join(config['pipelinedir'], "logs", "rmats", "{vs}.e"),
    params:
        dir = directory(join(config['workdir'], '01.rmats', '{vs}')),
        readlen=config['maxreadlen'],
    threads:
        8,
    container:
        config['container']['rmats'],
    shell:
        "mkdir -p {params.dir} \n"
        "cd {params.dir} \n"
        "rmats.py "
        "  --b1 {input.group0} "
        "  --b2 {input.group1} "
        "  --gtf {config[references][gtf]} "
        "  -t paired "
        "  --readLength {params.readlen} "
        "  --variable-read-length "
        "  --nthread {threads} "
        "  --od {params.dir} "
        "  --tmp {params.dir}/temp "
        "  --novelSS "
        " > {log.out} 2>{log.err} \n"
        "rm -rf tmp temp"
        " >> {log.out} 2>>{log.err} \n"
        "touch {output.ok}"

rule rmats_filter:
    input:
        ok = join(config['workdir'], '01.rmats', '{vs}', 'rmats.ok'),
    output:
        rijc = join(config['workdir'], '01.rmats', '{vs}','filtered','filtered_RI.MATS.JC.txt'),
    log:
        out = join(config['pipelinedir'], "logs", "rmats_filter", "{vs}.o"),
        err = join(config['pipelinedir'], "logs", "rmats_filter", "{vs}.e"),
    params:
        dir = directory(join(config['workdir'], '01.rmats', '{vs}','filtered')),
    threads:
        2,
    shell:
        "mkdir -p {params.dir} \n"
        "cd {params.dir}/.. \n"
        "python {config[pipelinedir]}/scripts/rmats_filtering.py A3SS.MATS.JC.txt \n"
        "python {config[pipelinedir]}/scripts/rmats_filtering.py A5SS.MATS.JC.txt \n"
        "python {config[pipelinedir]}/scripts/rmats_filtering.py MXE.MATS.JC.txt \n"
        "python {config[pipelinedir]}/scripts/rmats_filtering.py RI.MATS.JC.txt \n"
        "python {config[pipelinedir]}/scripts/rmats_filtering.py SE.MATS.JC.txt \n"
        "python {config[pipelinedir]}/scripts/rmats_filtering.py A3SS.MATS.JCEC.txt \n"
        "python {config[pipelinedir]}/scripts/rmats_filtering.py A5SS.MATS.JCEC.txt \n"
        "python {config[pipelinedir]}/scripts/rmats_filtering.py MXE.MATS.JCEC.txt \n"
        "python {config[pipelinedir]}/scripts/rmats_filtering.py RI.MATS.JCEC.txt \n"
        "python {config[pipelinedir]}/scripts/rmats_filtering.py SE.MATS.JCEC.txt \n"
        "mv filtered_* filtered/ \n"

rule rmats_plot:
    input:
        join(config['workdir'], '01.rmats', '{vs}','filtered','filtered_RI.MATS.JC.txt'),
        group0 = lambda wildcards: "{}/00.configs/Group.{}.txt".format(config['workdir'], combinations[wildcards.vs][0]),
        group1 = lambda wildcards: "{}/00.configs/Group.{}.txt".format(config['workdir'], combinations[wildcards.vs][1]),
    output:
        ok = join(config['workdir'], '01.rmats', '{vs}','filtered','sashimiplot','sashimiplot.ok'),
    params:
        dir = directory(join(config['workdir'], '01.rmats', '{vs}','filtered','sashimiplot')),
        name0 = lambda wildcards: combinations[wildcards.vs][0],
        name1 = lambda wildcards: combinations[wildcards.vs][1],
    log:
        out = join(config['pipelinedir'], "logs", "rmats_plot", "{vs}.o"),
        err = join(config['pipelinedir'], "logs", "rmats_plot", "{vs}.e"),
    threads:
        2,
    container:
        config['container']['rmats2sashimiplot'],
    shell:
        "mkdir -p {params.dir} \n"
        "cd {params.dir}/.. \n"
        "rmats2sashimiplot --b1 `cat {input.group0}` --b2 `cat {input.group1}` --event-type A3SS -e filtered_A3SS.MATS.JC.txt "
        "  --l1 {params.name0} --l2 {params.name1} --exon_s 1 --intron_s 5 -o sashimiplot \n"
        "rmats2sashimiplot --b1 `cat {input.group0}` --b2 `cat {input.group1}` --event-type A5SS -e filtered_A5SS.MATS.JC.txt "
        "  --l1 {params.name0} --l2 {params.name1} --exon_s 1 --intron_s 5 -o sashimiplot \n"
        "rmats2sashimiplot --b1 `cat {input.group0}` --b2 `cat {input.group1}` --event-type MXE -e filtered_MXE.MATS.JC.txt "
        "  --l1 {params.name0} --l2 {params.name1} --exon_s 1 --intron_s 5 -o sashimiplot \n"
        "rmats2sashimiplot --b1 `cat {input.group0}` --b2 `cat {input.group1}` --event-type RI -e filtered_RI.MATS.JC.txt "
        "  --l1 {params.name0} --l2 {params.name1} --exon_s 1 --intron_s 5 -o sashimiplot \n"
        "rmats2sashimiplot --b1 `cat {input.group0}` --b2 `cat {input.group1}` --event-type SE -e filtered_SE.MATS.JC.txt "
        "  --l1 {params.name0} --l2 {params.name1} --exon_s 1 --intron_s 5 -o sashimiplot \n"
        "touch {output.ok}"
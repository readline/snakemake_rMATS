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
        dir = directory(join(config['workdir'], '01.rmats', '{vs}')),
        ok = join(config['workdir'], '01.rmats', '{vs}', 'rmats.ok'),
    log:
        out = join(config['pipelinedir'], "logs", "rmats", "{vs}.o"),
        err = join(config['pipelinedir'], "logs", "rmats", "{vs}.e"),
    params:
        readlen=config['maxreadlen'],
    threads:
        8,
    container:
        config['container']['rmats'],
    shell:
        "cd {output.dir} \n"
        "rmats.py "
        "  --b1 {input.group0} "
        "  --b2 {input.group1} "
        "  --gtf {config[references][gtf]} "
        "  -t paired "
        "  --readLength {params.readlen} "
        "  --variable-read-length "
        "  --nthread {threads} "
        "  --od {output.dir} "
        "  --tmp {output.dir}/temp "
        "  --novelSS "
        " > {log.out} 2>{log.err} \n"
        "rm -rf tmp temp"
        " >> {log.out} 2>>{log.err} \n"
        "touch {output.ok}"
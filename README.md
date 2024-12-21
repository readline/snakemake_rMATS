# snakemake_RNApipe_hs
snakemake_RNApipe_hs


## Pipe Master

The master tool to control the pipeline. Funcions including:

1. Prepare cache container and reference

  ```bash
  # Required to assign
  -C, --cacheinit       Run the cache initiation.
  -c CACHEDIR, --cachedir=CACHEDIR
                        Directory of the cache to be used. Default:
                        /Path/to/pipeline/cache
  ```

2. Unlock the workdir

  ```bash
  # Required to assign
    -u, --unlock          Unlock the workdir from previous abnormal pipeline.
    -w WORKDIR, --workdir=WORKDIR
                          Directory to run the pipeline.
  ```

3. Run a pipeline

  ```bash
  # Required to assign
  -s SAMPLESHEET, --samplesheet=SAMPLESHEET
                        Samplesheet to be used for the pipeline.
  -w WORKDIR, --workdir=WORKDIR
                        Directory to run the pipeline.
  # Optional to assign

  ## If cache not located at default location (pipeline/cache)
  -c CACHEDIR, --cachedir=CACHEDIR
                        Directory of the cache to be used. Default:
                        /Path/to/pipeline/cache
  ## If want to skip certain modules
  -m, --skip_ctat_mutation
                        Skip CTAT mutation.
  -d, --skip_stringtie_denovo
                        Skip stringtie denovo.
  -f, --skip_fusion     Skip fusion detection.
  ```

```bash
./pipemaster.py -h
Usage: pipemaster.py [options]

Options:
  -h, --help            show this help message and exit
  -s SAMPLESHEET, --samplesheet=SAMPLESHEET
                        Samplesheet to be used for the pipeline.
  -w WORKDIR, --workdir=WORKDIR
                        Directory to run the pipeline.
  -c CACHEDIR, --cachedir=CACHEDIR
                        Directory of the cache to be used. Default:
                        /Path/to/pipeline/cache
  -C, --cacheinit       Run the cache initiation.
  -u, --unlock          Unlock the workdir from previous abnormal pipeline.
  -m, --skip_ctat_mutation
                        Skip CTAT mutation.
  -d, --skip_stringtie_denovo
                        Skip stringtie denovo.
  -f, --skip_fusion     Skip fusion detection.
```

## Rules

Snakefile is the core pipeline file. To avoid making the Snakefile too big, detail rules can be divided to several *.smk files located inside folder "rules".


## Config files

Separate config files in the *config* folder will be checked and merged, then placed at the *project/pipe_runtime/config.yaml*.


### Including

- config.yaml   \#Basic project config
- cluster.yaml  \#Configs for submitting tasks to slurm cluster
- container.yaml    \#Container information for cache
- reference.yaml    \#Reference information for cache

### Container

```yaml
cachedir: cache # Directory of cache, should be the same as Reference config
docker:         # Containers built and exists on the online registries, will be pulled to local.
    fastp:            docker://quay.io/biocontainers/fastp:0.23.4--hadf994f_2
simg:           # Containers exists online as pre-build image, will be downloaded directly
    stringtie:        https://depot.galaxyproject.org/singularity/stringtie%3A2.2.1--h6b7c446_4
```

### Reference

```yaml
cachedir: cache # Directory of cache, should be the same as Reference config
references:
  ctatplugnplay: # Title of the reference
    link:      https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/GRCh38_gencode_v37_CTAT_lib_Mar012021.plug-n-play.tar.gz # Link to download
    pack:      reference/GRCh38_gencode_v37_CTAT_lib_Mar012021.plug-n-play/ctat_genome_lib_build_dir # The folder/file will be used after unpack
    path:      reference/ctat_genome_lib_build_dir # The folder/file will be placed eventually
    clean:     # Folder/files will be removed after this reference is processed
       - reference/GRCh38_gencode_v37_CTAT_lib_Mar012021.plug-n-play
       - reference/GRCh38_gencode_v37_CTAT_lib_Mar012021.plug-n-play.tar.gz
```

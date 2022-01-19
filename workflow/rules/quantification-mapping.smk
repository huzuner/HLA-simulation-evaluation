rule kallisto_index:
    input:
        fasta = "resources/HLA-alleles/{genome}.fasta"
    output:
        index = "results/kallisto-index/{genome}.idx"
    params:
        extra = "--kmer-size=5"
    log:
        "logs/kallisto/index/{genome}.log"
    threads: 1
    wrapper:
        "0.74.0/bio/kallisto/index"

rule kallisto_quant:
    input:
        fastq = ["results/mixed/{sample}_1.fq", "results/mixed/{sample}_2.fq"],
        index = "results/kallisto-index/hla_gen.idx"
    output:
        directory('results/kallisto/quant_results_{sample}')
    params:
        extra = "-b 100"
    log:
        "logs/kallisto/kallisto_quant_{sample}.log"
    threads: 10
    wrapper:
        "0.74.0/bio/kallisto/quant"

rule bwa_index:
    input:
        "resources/hs_genome/{genome}.fasta"
    output:
        multiext("results/bwa-index/{genome}", ".amb", ".ann", ".bwt", ".pac", ".sa")
    log:
        "logs/bwa_index/{genome}.log"
    params:
        prefix="results/bwa-index/{genome}",
        algorithm="bwtsw" 
    wrapper:
        "0.74.0/bio/bwa/index"

rule bwa_mem:
    input:
        reads = ["results/mixed/{sample}_1.fq", "results/mixed/{sample}_2.fq"]
    output:
        "results/mapped/{sample}.bam"
    log:
        "logs/bwa_mem/{sample}.log"
    params:
        index="results/bwa-index/hs_genome",
        extra=r"-R '@RG\tID:{sample}\tSM:{sample}'",
        sort="samtools",             
        sort_order="coordinate",  
    threads: 2
    wrapper:
        "0.74.0/bio/bwa/mem"

rule samtools_index:
    input:
        "results/mapped/{sample}.bam"
    output:
        "results/mapped/{sample}.bam.bai"
    log:
        "logs/samtools_index/{sample}.log"
    wrapper:
        "0.74.0/bio/samtools/index"

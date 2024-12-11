
process GMAP_BUILD {
    tag "$meta.id"
    label 'process_medium'


    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1':
        'mdiblbiocore/gmap:latest' }"

    input:
    tuple val(meta), path(genome_fasta)


    output:
    tuple val(meta), path("${meta.id}/"), emit: index
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (genome_fasta.endsWith('.gz')){
        args = args + "-g"
    }
    """
    gmap_build -d ${meta.id} \\
    $args \\
    $genome_fasta

    mv /gmap_dbs/${meta.id} .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gmapgsnap: \$(gmap --version |& sed '1!d ; s/gmap //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch $genome_fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gmapgsnap: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}

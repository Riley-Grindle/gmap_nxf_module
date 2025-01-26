
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
    tuple val(meta), path("${meta.id}"), emit: index
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (genome_fasta.toString().endsWith('.gz')){
        args = args + "-g"
    }
    """
    WORK_DIR=\$(pwd)
    sed -i.bak 's|with_gmapdb=/path/to/gmapdb|with_gmapdb=\${WORK_DIR}|' /usr/src/app/gmap-2024-11-20/config.site
    
    /usr/src/app/gmap-2024-11-20/configure
    make
    make check
    make install

    gmap_build -d $prefix \\
    $args \\
    $genome_fasta

    mv /usr/local/share/$prefix .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gmapgsnap: \$(gmap --version |& sed '1!d ; s/gmap //')
    END_VERSIONS
    """

    stub:
    """
    touch $genome_fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gmapgsnap: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}

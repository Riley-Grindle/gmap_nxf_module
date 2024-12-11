
process GMAP {
    tag "$meta.id"
    label 'process_medium'


    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1':
        'mdiblbiocore/gmap:latest' }"

    input:
    tuple val(meta), path(gmap_db)
    tuple val(meta2), path(transcripts_fa)


    output:
    tuple val(meta), path("${meta.id2}"), emit: map_file
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    if (transcripts_fa.endsWith(".gz")){
        input_cdna = "<(gunzip -c $transcripts_fa)"
    }
    """
    mv $gmap_db /gmap_dbs/
    db=\$(basename $gmap_db)
    
    gmapl -d \$db \\
    $args \\
    -t $task.cpus \\
    $input_cdna > "${meta2.id}-map.${meta.id}"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gmapgsnap: \$(gmap --version |& sed '1!d ; s/gmap //')
    END_VERSIONS
    """

    stub:
    """
    touch $gmap_db
    touch $transcripts_fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gmapgsnap: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}

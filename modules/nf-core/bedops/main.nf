
process GTF2BED {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1':
        'quay.io/biocontainers/bedops:2.4.40--h9f5acd7_0' }"

    input:
    tuple val(meta), path(gtf)

    output:
    tuple val(meta), path("${meta.id}.bed"), emit: bed_file
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    if (gtf.toString().endsWith(".gz")){
        input_gtf = "<(gunzip -c $gtf)"
    } else {
        input_gtf = "$gtf"
    }
    """

    gtf2bed < $input_gtf > ${meta.id}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gmapgsnap: \$(gtf2bed --version |& sed '1!d ; s/gtf2bed //')
    END_VERSIONS
    """

    stub:
    """
    touch $gtf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gmapgsnap: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}

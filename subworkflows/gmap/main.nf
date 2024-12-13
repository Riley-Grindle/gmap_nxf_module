include { GMAP_BUILD        } from '../../modules/nf-core/gmap_build/main'
include { GMAP              } from '../../modules/nf-core/gmap/main'


workflow GMAP_GENOME {
    take:
    genome_fasta                //      channel: [meta, /path/to/genome.fasta]
    transcripts_fa              //      file: [meta, /path/to/transcripts.fasta]


    main:

    GMAP_BUILD(
        genome_fasta
    )

    GMAP(
        GMAP_BUILD.out.index,
        transcripts_fa
    )

    emit:
    map = GMAP.out.map_file
}


workflow {
    genome_ch     = Channel.of( [ [id: params.genome_name], params.genome_fasta ] )
    transcript_ch = Channel.of( [ [id: params.tx_name], params.tx_fasta ] )

    GMAP_GENOME(
        genome_ch, 
        transcript_ch
    )
}
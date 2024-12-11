include { GMAP_BUILD        } from '../../modules/nf-core/gmap_build/main'
include { GMAP              } from '../../modules/nf-core/gmap/main'


workflow GMAP_GENOME {
    take:
    genome_fasta                //      file: /path/to/genome.fasta
    transcripts_fa              //      file: /path/to/transcripts.fasta


    main:

    GMAP_BUILD(
        Channel.of([ [id:params.genome_name], genome_fasta ])
    )

    GMAP(
        GMAP_BUILD.out.index,
        Channel.of([ [id:params.tx_name], transcripts_fa ])
    )

    emit:
    map = GMAP.out.map_file
}

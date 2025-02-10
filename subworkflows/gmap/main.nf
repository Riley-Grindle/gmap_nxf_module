include { GMAP_BUILD        } from '../../modules/nf-core/gmap_build/main'
include { GMAP              } from '../../modules/nf-core/gmap/main'
include { GMAP_L            } from '../../modules/nf-core/gmap_l/main'
include { GTF2BED as GTF2BED_QUERY } from '../../modules/nf-core/bedops/main'
include { GTF2BED as GTF2BED_REF } from '../../modules/nf-core/bedops/main'
include { BEDTOOLS_INTERSECT } from '../../modules/nf-core/bedtools/main'

workflow GMAP_GENOME {
    take:
    genome_fasta                //      channel: [meta, /path/to/genome.fasta]
    genome_gtf                  //      file: [meta, /path/to/genome.gtf]
    transcripts_fa              //      file: [meta, /path/to/transcripts.fasta]


    main:

    if (!params.gmap_index){
        
        GMAP_BUILD(
            genome_fasta
        )
        GMAP_L(
            GMAP_BUILD.out.index, 
            transcripts_fa
        )

    } else {

        ch_index = Channel.of( [ [id: params.genome_name], params.gmap_index ] )

        GMAP_L(
            ch_index, 
            transcripts_fa
        )

    }
    /*
    ch_genome_index = GMAP_BUILD(
        genome_fasta
    )
    */
    // check size of genome fasta if it is larger than 2 billion bytes, then use use GMAP_L instead of GMAP

    /*
    genome_fasta
        .map { meta, file -> [meta, file, file.size()] }
    
    ch_genome_index.mix(genome_fasta)
    .groupTuple()
    .set { sized_and_indexed_ch }

    GMAP_L(
        sized_and_indexed_ch.map { [ it[0], it[1], it[2] ]}, 
        transcripts_fa
    )

    */

    GTF2BED_QUERY(
        GMAP_L.out.map_file
    )

    GTF2BED_REF(
        genome_gtf
    )

    BEDTOOLS_INTERSECT(
        GTF2BED_QUERY.out.bed_file,
        GTF2BED_REF.out.bed_file
    )

    emit:
    map = BEDTOOLS_INTERSECT.out.intersect
}


workflow {
    genome_fa_ch  = Channel.of( [ [id: params.genome_name], params.genome_fasta ] )
    transcript_ch = Channel.of( [ [id: params.tx_name], params.tx_fasta ] )
    genome_gtf_ch = Channel.of( [ [id: params.genome_name], params.genome_gtf ] )

    GMAP_GENOME(
        genome_fa_ch, 
        genome_gtf_ch,
        transcript_ch
    )
}
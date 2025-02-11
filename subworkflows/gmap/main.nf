include { GUNZIP                   } from '../../modules/nf-core/gunzip/main'
include { GMAP_BUILD               } from '../../modules/nf-core/gmap_build/main'
include { GMAP                     } from '../../modules/nf-core/gmap/main'
include { GTF2BED as GTF2BED_QUERY } from '../../modules/nf-core/bedops/main'
include { GTF2BED as GTF2BED_REF   } from '../../modules/nf-core/bedops/main'
include { BEDTOOLS_INTERSECT       } from '../../modules/nf-core/bedtools/main'

workflow GMAP_GENOME {
    take:
    genome_fasta                //      channel: [meta, /path/to/genome.fasta]
    genome_gtf                  //      file: [meta, /path/to/genome.gtf]
    transcripts_fa              //      file: [meta, /path/to/transcripts.fasta]


    main:

    if (!params.gmap_index){
        
        if (params.genome_fasta.endsWith(".gz")){
            ch_genome_fasta = GUNZIP(
                genome_fasta
            ).gunzip
        } else {
            ch_genome_fasta = genome_fasta
        }


        ch_genome_index = GMAP_BUILD(
            ch_genome_fasta
        )

        ch_genome_index.index.mix(ch_genome_fasta)
        .groupTuple()
        .flatten()
        .collect()
        .set { ch_sized_and_indexed }
        ch_sized_and_indexed.view()

        GMAP(
            ch_sized_and_indexed.map { [ it[0], it[1], it[2] ]}, 
            transcripts_fa
        )

    } else {

        if (params.genome_fasta.endsWith(".gz")){
            ch_genome_fasta = GUNZIP(
                genome_fasta
            ).gunzip
        } else {
            ch_genome_fasta = genome_fasta
        }

        ch_genome_index = Channel.of( [ [id: params.genome_name], params.gmap_index ] )

        ch_genome_index.mix(ch_genome_fasta)
        .groupTuple()
        .flatten()
        .collect()
        .set { ch_sized_and_indexed }
        ch_sized_and_indexed.view()

        GMAP(
            ch_sized_and_indexed.map { [ it[0], it[1], it[2] ]}, 
            transcripts_fa
        )

    }

    GTF2BED_QUERY(
        GMAP.out.map_file
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
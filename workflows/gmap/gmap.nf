include { GUNZIP as GUNZIP_FA         } from '../../modules/nf-core/gunzip/main'
include { GUNZIP as GUNZIP_GTF        } from '../../modules/nf-core/gunzip/main'
include { GMAP_BUILD                  } from '../../modules/nf-core/gmap_build/main'
include { GMAP                        } from '../../modules/nf-core/gmap/main'
include { GTF2BED as GTF2BED_QUERY    } from '../../modules/nf-core/bedops/main'
include { GTF2BED as GTF2BED_REF      } from '../../modules/nf-core/bedops/main'
include { BEDTOOLS_INTERSECT          } from '../../modules/nf-core/bedtools/main'
include { GFFCOMPARE                  } from '../../modules/nf-core/gffcompare/main'

workflow GMAP_GENOME {


    genome_fasta  = Channel.of( [ [id: params.genome_name], params.genome_fasta ] )
    transcripts_fa = Channel.of( [ [id: params.tx_name], params.tx_fasta ] )
    genome_gtf = Channel.of( [ [id: params.genome_name], params.genome_gtf ] )
    
    if (!params.gmap_index){
        
        if (params.genome_fasta.endsWith(".gz")){
            ch_genome_fasta = GUNZIP_FA(
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

        if (!params.gmap_results){
            GMAP(
                ch_sized_and_indexed.map { [ it[0], it[1], it[2] ]}, 
                transcripts_fa
            )

            GTF2BED_QUERY(
                GMAP.out.map_file
            )

            if (params.genome_gtf.endsWith('.gz')){
                ch_genome_gtf = GUNZIP_GTF(
                    genome_gtf
                ).gunzip
            } else {
                ch_genome_gtf = genome_gtf
            }

            GFFCOMPARE(
                GMAP.out.map_file,
                ch_genome_fasta,
                ch_genome_gtf
            )
        } else {
            ch_gmap_results = Channel.of([ [id: params.tx_name], params.gmap_results ])

            GTF2BED_QUERY(
                ch_gmap_results
            )

            if (params.genome_gtf.endsWith('.gz')){
                ch_genome_gtf = GUNZIP_GTF(
                    genome_gtf
                ).gunzip
            } else {
                ch_genome_gtf = genome_gtf
            }            

            GFFCOMPARE(
                ch_gmap_results,
                ch_genome_fasta,
                ch_genome_gtf
            )  
        }

    } else {

        if (params.genome_fasta.endsWith(".gz")){
            ch_genome_fasta = GUNZIP_FA(
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

        if (!params.gmap_results){
            GMAP(
                ch_sized_and_indexed.map { [ it[0], it[1], it[2] ]}, 
                transcripts_fa
            )

            GTF2BED_QUERY(
                GMAP.out.map_file
            )

            if (params.genome_gtf.endsWith('.gz')){
                ch_genome_gtf = GUNZIP_GTF(
                    genome_gtf
                ).gunzip
            } else {
                ch_genome_gtf = genome_gtf
            }

            GFFCOMPARE(
                GMAP.out.map_file,
                ch_genome_fasta,
                ch_genome_gtf
            )
        } else {
            ch_gmap_results = Channel.of([ [id: params.tx_name], params.gmap_results ])

            GTF2BED_QUERY(
                ch_gmap_results
            )

            if (params.genome_gtf.endsWith('.gz')){
                ch_genome_gtf = GUNZIP_GTF(
                    genome_gtf
                ).gunzip
            } else {
                ch_genome_gtf = genome_gtf
            }

            GFFCOMPARE(
                ch_gmap_results,
                ch_genome_fasta,
                ch_genome_gtf
            )  
        }
    }


    GTF2BED_REF(
        ch_genome_gtf
    )

    BEDTOOLS_INTERSECT(
        GTF2BED_QUERY.out.bed_file,
        GTF2BED_REF.out.bed_file
    )

}

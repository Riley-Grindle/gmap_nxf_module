#!/usr/bin/bash

cat > params.json << EOF
params {
    genome_name = "UKY_AmexF1_1"
    genome_fasta = "s3://mdibl-reference/a.mexicanum/internal/GCF_040938575.1_UKY_AmexF1_1_genomic.fna.gz"
    genome_gtf = "s3://mdibl-reference/a.mexicanum/internal/GCF_040938575.1_UKY_AmexF1_1_genomic.FIXED.gtf"
    gmap_index = "s3://mdibl-reference/a.mexicanum/internal/ukyGmapFiles/gmap_db/UKY_AmexF1_1/"
    gmap_results = ""
    tx_fasta = "s3://mdibl-reference/a.mexicanum/internal/ukyGmapFiles/txFasta/StringtieMerged/Merged_AmexT_AmexG6_stringtieFix_final.fa.gz"
    tx_name = "Merged_AmexT_AmexG6_stringtieFix_final"
    outdir = "s3://mdibl-rseaman/nextflowOutput/Merged_AmexT_AmexG6_stringtieFix_final_VS_UKY_AmexF1_1/"
    publish_dir_mode = "copy"
}
process {
    withName: "GMAP_BUILD" {
        publishDir = [
                    path: { "${params.outdir}/gmap_db/" },
                    mode: params.publish_dir_mode,
                    saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }
        withName: "GMAP" {
        publishDir = [
                    path: { "${params.outdir}/gmap/" },
                    mode: params.publish_dir_mode,
                    saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }
    withName: "GTF2BED" {
        publishDir = [
                    path: { "${params.outdir}/gtf2bed/" },
                    mode: params.publish_dir_mode,
                    saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }
        withName: "BEDTOOLS_INTERSECT" {
            publishDir = [
                    path: { "${params.outdir}/bedtools_intersect/" },
                    mode: params.publish_dir_mode,
                    saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
        ext.args = "-wa -wb -f 0.50"
        ext.suffix = ".bed"
    }
    withName: "GFFCOMPARE" {
        publishDir = [
                    path: { "${params.outdir}/gffcompare/" },
                    mode: params.publish_dir_mode,
                    saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }
}
profiles {
    debug {
        dumpHashes             = true
        process.beforeScript   = 'echo $HOSTNAME'
        cleanup                = false
    }
    conda {
        conda.enabled          = true
        docker.enabled         = false
        singularity.enabled    = false
        podman.enabled         = false
        shifter.enabled        = false
        charliecloud.enabled   = false
        apptainer.enabled      = false
    }
    mamba {
        conda.enabled          = true
        conda.useMamba         = true
        docker.enabled         = false
        singularity.enabled    = false
        podman.enabled         = false
        shifter.enabled        = false
        charliecloud.enabled   = false
        apptainer.enabled      = false
    }
    docker {
        docker.enabled         = true
        docker.userEmulation   = true
        conda.enabled          = false
        singularity.enabled    = false
        podman.enabled         = false
        shifter.enabled        = false
        charliecloud.enabled   = false
        apptainer.enabled      = false
    }
    arm {
        docker.runOptions = '-u $(id -u):$(id -g) --platform=linux/amd64'
    }
    singularity {
        singularity.enabled    = true
        singularity.autoMounts = true
        conda.enabled          = false
        docker.enabled         = false
        podman.enabled         = false
        shifter.enabled        = false
        charliecloud.enabled   = false
        apptainer.enabled      = false
    }
    podman {
        podman.enabled         = true
        conda.enabled          = false
        docker.enabled         = false
        singularity.enabled    = false
        shifter.enabled        = false
        charliecloud.enabled   = false
        apptainer.enabled      = false
    }
    shifter {
        shifter.enabled        = true
        conda.enabled          = false
        docker.enabled         = false
        singularity.enabled    = false
        podman.enabled         = false
        charliecloud.enabled   = false
        apptainer.enabled      = false
    }
    charliecloud {
        charliecloud.enabled   = true
        conda.enabled          = false
        docker.enabled         = false
        singularity.enabled    = false
        podman.enabled         = false
        shifter.enabled        = false
        apptainer.enabled      = false
    }
    apptainer {
        apptainer.enabled      = true
        conda.enabled          = false
        docker.enabled         = false
        singularity.enabled    = false
        podman.enabled         = false
        shifter.enabled        = false
        charliecloud.enabled   = false
    }
    gitpod {
        executor.name          = 'local'
        executor.cpus          = 16
        executor.memory        = 60.GB
    }
}
EOF

#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process munge_sumstats {
    label 'med_mem'

    input:
        tuple path(sumstats),
            val(N),
            path(hampmap3_snps),
            path(munge_sumstats_script)
    output:
        path("${sumstats.getSimpleName()}.sumstats.gz")
    script:
        """
        python ./munge_sumstats.py \
        --out ${sumstats.getBaseName()} \
        --merge-alleles $hapmap3_snps \
        --chunksize 500000 \
        --sumstats $sumstats
        """   
}
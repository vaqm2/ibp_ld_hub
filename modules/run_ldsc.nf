#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process run_ldsc {
    label 'med_mem'

    input:
        tuple path(trait1),
        path(trait2),
        path(ld_files),
        val(out_prefix)
    output:
        path("${out_prefix}.rG.txt")
    script:
        """
        python ./ldsc.py \
        --ref-ld-chr ${task.workDir} \
        --out ${out_prefix} \
        --rg $trait1,$trait2 \
        --w-ld-chr ${task.workDir}

        grep -A 2 "Summary of Genetic Correlation Results" ${out_prefix}.log | tail -n 2 > ${out_prefix}.rG.txt
        """
}
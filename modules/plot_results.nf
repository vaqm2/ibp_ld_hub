#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

process plot_results {
    label 'low_mem'

    input:
        tuple path(rG),
        val(out_prefix),
        path(forest_plot_script_path)
    output:
        path("${out_prefix}_rG.png")
    script:
        """
        Rscript ./forest_plot.R ${rG} ${out_prefix}
        """
}
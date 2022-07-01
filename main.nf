#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { munge_sumstats as munge_sumstats_trait } from './modules/munge_sumstats.nf'
include { munge_sumstats as munge_sumstats_targets } from './modules/munge_sumstats.nf'
include { run_ldsc } from './modules/run_ldsc.nf'
include { plot_results } from './modules/plot_results.nf'

def help_message() {
    log.info """
    IBP version of now defunct LD-Hub pipeline
    Author: Vivek Appadurai | Senior Postdoctoral Researcher | vivek.appadurai@regionh.dk

    Usage: nextflow run main.nf

    Options:

    --sumstats <phenotype.assoc> [Summary stats for which you wish to compute genetic correlations]
    --n <10000> [Sample size for GWAS from which the summary statistics were derived]
    --targets <file.txt> [Paths of summary stats of traits for which you wish to compute genetic correlations with your trait of interest]
    --out <output_prefix> [Prefix for output files and plots]
    --help prints this message
    """
}

if(params.help) {
    help_message()
    exit()
}

log.info """
================================================================================================
IBP - LD HUB PIPELINE V1.0 - NF
================================================================================================
Summary stats for trait1                : $params.sumstats
Sample size for trait1                  : $params.n
Path of summary stats for target traits : $params.targets
Output prefix                           : $params.out
================================================================================================
"""

workflow {
    // Munge Summmary statistics file for trait

    Channel.fromPath(params.sumstats) \
    | combine(Channel.of(params.n))
    | combine(Channel.fromPath(params.hm3_snps)) \
    | combine(Channel.fromPath(params.munge_sumstats_path)) \
    | munge_sumstats_trait \
    | set { munged_sumstats_ch }

    // Munge Summmary statistics files for targets

    Channel.fromPath(params.targets).splitText() { it.trim() } \
    | combine(Channel.fromPath(params.hm3_snps)) \
    | combine(Channel.fromPath(munge_sumstats_path)) \
    | munge_sumstats_targets \
    | set { munged_targets_ch }

    //Run LDSC

    munged_sumstats_ch \
    | combine(params.munged_targets_ch) \
    | combine(Channel.fromPath("$params.ld_path/*")) \
    | combine(Channel.of(params.out)) \
    | run_ldsc \
    | collectFile(name: "$params.out".rG.txt, keepHeader = true, skip: 1)
    | set { rG_out_ch }

    // Plot results

    rG_out_ch \
    | combine(Channel.of(params.out)) \
    | combine(Channel.of(forest_plot_script_path))
    | plot_results
}
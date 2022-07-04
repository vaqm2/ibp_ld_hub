#!/usr/bin/env Rscript 

require(ggplot2, quietly = TRUE)
require(dplyr, quietly = TRUE)

args = commandArgs(trailingOnly = TRUE)
rG_table = read.table(args[1], header = T)
out_prefix = args[2]

rG_table = rG_table %>% 
    select(p1, p2, se, rg, p) %>% 
    mutate(p_fdr = p.adjust(p, method = c("fdr"), n = nrow(rG_table))) %>%
    mutate(Significant = ifelse(p_fdr < 0.05, "Yes", "No"))

rG_table$p1 = gsub("\\..*$", "", rG_table$p1)
rG_table$p2 = gsub("\\..*$", "", rG_table$p2)
    
png(paste0(out_prefix, "_ldsc_rg.png"), 
    width = 10, 
    height = 12, 
    units = "in",
    res = 300)

ggplot(rG_table, aes(x = rg, y = p2, color = Significant)) + 
    geom_point() + 
    geom_errorbarh(aes(xmin = rg - 1.96 * se, xmax = rg + 1.96 * se), 
                   height = 0.01) +
    geom_label(aes(value = p_fdr)) +
    geom_vline(xintercept = 0, lty = 2) +
    theme_bw() +
    scale_color_manual(values = c("red", "blue")) +
    labs(caption = out_prefix)

dev.off()
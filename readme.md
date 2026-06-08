# CircRNA Dysregulation in ALS

## Project Overview
Identification and differential expression analysis of circular RNAs across amyotrophic lateral sclerosis (ALS), ALS with cognitive impairment, and healthy control samples using total RNA-seq data [GSE314526](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE314526).

## Biological Question
Which circRNAs specifically associate with cognitive decline in ALS, and do they implicate any regulatory networks?

## Proposed Pipeline
Raw FASTQ → FastQC → Fastp → BWA-mem (T19) → CIRI2 → CIRIquant → DESeq2 → ceRNA network analysis

## Tools
- BWA-mem 0.7.17
- CIRI2 v2.0.6
- CIRIquant
- DESeq2
- Docker (local)

## Status
- [x] Pipeline developed and tested on subset data
- [x] Pilot CIRI2 output generated (see results/pilot/)
- [ ] Full sample processing in progress
- [ ] DESeq2 differential expression analysis
- [ ] ceRNA network construction
- [ ] TDP-43 crossreference

## Results
Analysis in progress. Results will be updated as samples are processed.
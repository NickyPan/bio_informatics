java -XX:ParallelGCThreads=1 -jar /opt/seqtools/gatk/GenomeAnalysisTK.jar \
-T DepthOfCoverage -I $1 -L /opt/seqtools/bed/IDT_Exome_CNV.intervals \
-R /opt/seqtools/gatk/ucsc.hg19.fasta \
-dt BY_SAMPLE -dcov 5000 -l INFO  \
--minBaseQuality 0 --minMappingQuality 20 \
--start 1 --stop 5000 --nBins 200 \
--includeRefNSites \
--countType COUNT_FRAGMENTS \
-o group3.DATA
xhmm --mergeGATKdepths -o DATA.RD.txt --GATKdepths /mnt/workshop/SC/project/paternity/XHMM_cnv/group1.DATA.sample_interval_summary --GATKdepths  group3.DATA.sample_interval_summary
xhmm --matrix -r DATA.RD.txt --centerData --centerType target -o DATA.filtered_centered.RD.txt --outputExcludedTargets DATA.filtered_centered.RD.txt.filtered_targets.txt --outputExcludedSamples DATA.filtered_centered.RD.txt.filtered_samples.txt --excludeTargets /mnt/workshop/SC/project/paternity/XHMM_cnv/extreme_gc_targets.txt --excludeTargets /mnt/workshop/SC/project/paternity/XHMM_cnv/low_complexity_targets.txt --minTargetSize 10 --maxTargetSize 10000 --minMeanTargetRD 10 --maxMeanTargetRD 500 --minMeanSampleRD 25 --maxMeanSampleRD 200 --maxSdSampleRD 150
xhmm --PCA -r DATA.filtered_centered.RD.txt --PCAfiles DATA.RD_PCA
xhmm --normalize -r DATA.filtered_centered.RD.txt --PCAfiles DATA.RD_PCA --normalizeOutput DATA.PCA_normalized.txt --PCnormalizeMethod PVE_mean --PVE_mean_factor 0.7
xhmm --matrix -r DATA.PCA_normalized.txt --centerData --centerType sample --zScoreData -o DATA.PCA_normalized.filtered.sample_zscores.RD.txt --outputExcludedTargets DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_targets.txt --outputExcludedSamples DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_samples.txt --maxSdTargetRD 30
xhmm --matrix -r DATA.RD.txt --excludeTargets DATA.filtered_centered.RD.txt.filtered_targets.txt --excludeTargets DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_targets.txt --excludeSamples DATA.filtered_centered.RD.txt.filtered_samples.txt --excludeSamples DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_samples.txt -o DATA.same_filtered.RD.txt
xhmm --discover -p /mnt/workshop/SC/project/paternity/XHMM_cnv/params.txt -r DATA.PCA_normalized.filtered.sample_zscores.RD.txt -R DATA.same_filtered.RD.txt -c DATA.xcnv -a DATA.aux_xcnv -s DATA
awk '{print $3}' DATA.xcnv > DATA.xcnv.intervals
pseq . loc-intersect --group refseq --locdb /home/xiaoliang.tian/software/plinkseq/hg19/locdb --file DATA.xcnv.intervals --out annotated_targets.refseq
paste DATA.xcnv annotated_targets.refseq.loci > DATA.xcnv.result
#!/usr/bin/perl
use strict;
use warnings;

my @cmd_vcf;
my $cmd_anno;
my $out_name;
my @sp_name;
push @cmd_vcf,"java -XX:ParallelGCThreads=1 -jar /opt/seqtools/gatk/GenomeAnalysisTK.jar \\";
push @cmd_vcf,"        -T GenotypeGVCFs \\";
push @cmd_vcf,"        -R /opt/seqtools/gatk/ucsc.hg19.fasta \\";
foreach my $sp (@ARGV) {
    my @tmp_name=split('_',$sp);
    push @sp_name, $tmp_name[0];
    push @cmd_vcf,"        -V ./$sp \\";
}
$out_name= join"_",@sp_name;
push @cmd_vcf,"        -o ./$out_name.combined.raw.vcf";

$cmd_anno="table_annovar.pl ./$out_name.combined.raw.vcf /opt/seqtools/annovar/humandb -buildver hg19 -out ./$out_name.combined.anno -remove -protocol refGene,1000g2015aug_all,1000g2015aug_eas,dbscsnv11,cosmic70,clinvar_20170905,avsnp150,exac03,esp6500siv2_all,esp6500siv2_ea,dbnsfp33a -operation g,f,f,f,f,f,f,f,f,f,f -nastring . -vcfinput";

my $re=join"\n",@cmd_vcf;
print "$re\n";
print "$cmd_anno\n";
print "是否执行程序(y/n): ";
my $is_continued = <STDIN>;
chomp $is_continued;
if ($is_continued eq "y") {
  print "processing....\n";
  system($re);
  print "raw_vcf generated\n";
  system($cmd_anno);
  print "annovar done\n";
} else {
  die "stopped!\n";
}

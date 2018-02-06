#!/usr/bin/perl
use strict;
use warnings;

print "@ARGV\n";

my @cmd_vcf;
my $out_name;
my @sp_name;
push @cmd_vcf,"nohup java -XX:ParallelGCThreads=1 -jar /opt/seqtools/gatk/GenomeAnalysisTK.jar \\";
push @cmd_vcf,"        -T GenotypeGVCFs \\";
push @cmd_vcf,"        -R /opt/seqtools/gatk/ucsc.hg19.fasta \\";
foreach my $sp (@ARGV) {
    my @tmp_name=split('_',$sp);
    push @sp_name, $tmp_name[0];
    push @cmd_vcf,"        -V ./$sp \\";
}
$out_name= join"_",@sp_name;
push @cmd_vcf,"        -o ./$out_name.combined.raw.vcf &";

my $re=join"\n",@cmd_vcf;
print "$re\n";
print "是否执行程序(y/n): ";
my $is_continued = <STDIN>;
chomp $is_continued;
  print "$is_continued\n";
if ($is_continued eq "y") {
  print "processing....\n";
  system($re);
} else {
  print "stopped!\n";
}

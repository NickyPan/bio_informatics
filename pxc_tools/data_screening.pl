#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

die "Usage:
    perl [script] -i [sample_list] -o [output_sh_file] -s [sh_dir] -g [gatk_dir] -f [fastq_dir] \n

            -cat  need to cat files
            -fpa cat file path a
            -fpb cat file path b
            -fpo cat file output path
            -bed  bed type
            -t	sequencing type
            -fd	file_dir
            -s	sh_dir
            -g	gatk_dir
            -f  fastq_dir
            -nl  file name length"

 unless @ARGV>=1;

my $is_cat;
my $file_path_a;
my $file_path_b;
my $file_path_out;
my $file_type;
my $bed;
my $type;
my $filedir;
my $sh_dir;
my $fq_dir;
my $gk_dir;
my $name_length;

Getopt::Long::GetOptions (
    'cat+'  => \$is_cat,
    'fpa=s' => \$file_path_a,
    'fpb=s' => \$file_path_b,
    'fpo=s' => \$file_path_out,
    'bed=s' => \$bed,
    't=s' => \$type,
    'fd=s' => \$filedir,
    's:s' => \$sh_dir,
    'g:s' => \$gk_dir,
    "f:s" => \$fq_dir,
    "nl=s" => \$name_length,
);

my $basedir = "./";

my @file_list=();
my @dir;
my @sample_list;
my @cat_list;

my %dir=(
    "wesv3"=>"/mnt/workshop/xinchen.pan/project/WES",
    "wesmd"=>"/mnt/workshop/xinchen.pan/project/WES",
    "WCQZ"=>"/mnt/workshop/xinchen.pan/project/WCQZ",
    "tp53"=>"/mnt/workshop/xinchen.pan/project/TP53",
    "50gene"=>"/mnt/workshop/xinchen.pan/project/50gene",
    "zls"=>"/mnt/workshop/xinchen.pan/project/ZLS",
    "fevr"=>"/mnt/workshop/xinchen.pan/project/FEVR",
    "wgs"=>"/mnt/workshop/xinchen.pan/project/WGS",
    "egfr_jcq"=>"/mnt/workshop/xinchen.pan/project/EGFR",
    "EGFR"=>"/mnt/workshop/xinchen.pan/project/EGFR",
    "ET"=>"/mnt/workshop/xinchen.pan/project/ET",
    "et"=>"/mnt/workshop/xinchen.pan/project/ET",
    "ZS"=>"/mnt/workshop/xinchen.pan/project/ZS",
    "eye_449"=>"/mnt/workshop/xinchen.pan/project/WES/eye",
    "XLT"=>"/mnt/workshop/xinchen.pan/project/XLT/",
    "chrM"=>"/mnt/workshop/xinchen.pan/project/CHRM",
    "brca"=>"/mnt/workshop/xinchen.pan/project/Brca",
    "ppgl"=>"/mnt/workshop/xinchen.pan/project/PPGL",
);

my %bed_list=(
    "wesv3"=>"SeqCap_EZ_Exome_v3_capture.intervals",
    "wesmd"=>"MedExome_hg19_capture_targets.intervals",
    "WCQZ"=>"WCQZ.intervals",
    "50gene"=>"50gene.intervals",
    "tp53"=>"tp53.intervals",
    "zls"=>"zls201.intervals",
    "fevr"=>"fevr.intervals",
    "egfr_jcq"=>"egfr_jcq.intervals",
    "EGFR"=>"EGFR.intervals",
    "ET"=>"ET.intervals",
    "et"=>"et.intervals",
    "ZS"=>"ZS.intervals",
    "eye_449"=>"eye_449.intervals",
    "XLT"=>"XLT.intervals",
    "chrM"=>"chrM.intervals",
    "brca"=>"brca.intervals",
    "ppgl"=>"PPGL.intervals"
);

my %raw_vcf;
my %merge;
my %mg;
my %result;
my %log;
my %summary;
my @output;
my %dir_check;

opendir (DIR, $basedir) or die "can't open the directory!";
@dir = readdir DIR;
if($is_cat) {
    open CATLIST, ">./cat_list" or die "Can not create cat_list\n";
    foreach my $file (@dir) {
        if ( $file =~ /[a-z]*\.fastq.gz/) {
            push (@file_list , $file);
            syn_cat_list($file);
        }
    }
    my $cat_list=join"", @cat_list;
    print CATLIST "$cat_list";
    print "cat_list process is done\n";
} else {
    open RE, ">./result_list" or die "Can not create result_list\n";

    foreach my $file (@dir) {
        if ( $file =~ /[a-z]*R1\.fastq.gz/) {
            push (@file_list , $file);
            syn_result_list($file);
        }
    }

    my @key=keys %raw_vcf;
    foreach my $key (@key){
        my @sample=split/\t/,$raw_vcf{$key};
        push @output,"java -XX:ParallelGCThreads=1 -jar /opt/seqtools/gatk/GenomeAnalysisTK.jar \\ ";
        push @output,"        -T GenotypeGVCFs \\ ";
        push @output,"        -R $gk_dir/ucsc.hg19.fasta \\ ";
        foreach my $sp (@sample) {
            push @output,"        -V $result{$key}/$sp \\ ";
        }
        push @output,"        -o $result{$key}/$key.raw.vcf ";

        push @output,"table_annovar.pl $result{$key}/$key.raw.vcf /opt/seqtools/annovar/humandb -buildver hg19 -out $result{$key}/$key.anno -remove -protocol refGene,1000g2015aug_all,1000g2015aug_eas,dbscsnv11,cosmic70,clinvar_20170905,avsnp150,exac03,esp6500siv2_all,esp6500siv2_ea,dbnsfp33a -operation g,f,f,f,f,f,f,f,f,f,f -nastring . -vcfinput"
    }

    my $re=join"\n",@output;
    print RE $re;
    print "result_list process done!\n";
}

sub syn_cat_list {
    my $name= $_[0];
    if($is_cat && $file_path_a && $file_path_b && $file_path_out) {
        push @cat_list, "cat $file_path_a/$name $file_path_b/$name > $file_path_out/$name\necho \"end $name\"\n";
    } else {
        die "please input all variables below\n
            -cat  need to cat files
            -fpa cat file path a
            -fpb cat file path b
            -fpo cat file output path";
    }
}

sub syn_result_list {
    my $name= $_[0];
    my $step1_sh=$type."_"."pe"."_step1.sh";
    my $sample=substr($name,0,length($name)-$name_length);

    my $out_dir=$dir{$bed}."/".$filedir;
    if(!exists($dir_check{$out_dir})) {
        mkdir $out_dir;
        $dir_check{$out_dir}=1;
    }

    my $result_dir=$out_dir."/result";
    if(!exists($dir_check{$result_dir})){
        mkdir $result_dir;
        $dir_check{$result_dir}=1;
    }

    my $summary_dir=$out_dir."/summary";
    if(!exists($dir_check{$summary_dir})){
        mkdir $summary_dir;
        $dir_check{$summary_dir}=1;
    }

    my $log_dir=$out_dir."/log";
    if(!exists($dir_check{$log_dir})) {
        mkdir $log_dir;
        $dir_check{$log_dir}=1;
    }

    $result{$name}=$result_dir;
    $summary{$name}=$summary_dir;
    $log{$name}=$log_dir;

    # if($line[5]eq 0 ){
        if(!exists($raw_vcf{$name})) {
            $raw_vcf{$name}=$sample.".g.vcf";
        } else {
            $raw_vcf{$name}.="\t$sample.g.vcf";
        }
        my $rest=join" ",("nohup", "sh", "$sh_dir/$step1_sh", $sample, $gk_dir, $fq_dir, $result_dir, $summary_dir, $log_dir, $bed_list{$bed}, "&");
        push @output,$rest;
    # } else {
        # $merge{$line[5]}++;
        # if(!exists($mg{$line[5]})) {
        #     $mg{$line[5]}=$line[0];
        # } else {
        #     $mg{$line[5]}.="\t$line[0]";
        # }

        # if($merge{$line[5]}>=2){
        #     $sample=substr($line[5],0,length($line[5])-12);
        #     if(!exists($raw_vcf{$line[4]})) {
        #         $raw_vcf{$line[4]}=$sample.".g.vcf";
        #     } else {
        #         $raw_vcf{$line[4]}.="\t$sample.g.vcf";
        #     }

        #     my @l12=split/\t/,$mg{$line[5]};
        #     push @output,"cat $fq_dir/$l12[0] $fq_dir/$l12[1] > $fq_dir/$line[5]";
        #     #  $sample=substr($line[5],0,length($line[5])-16);
        #     my $rest=join" ",("sh","$sh_dir/$step1_sh",$sample,$gk_dir,$fq_dir,$result_dir,$summary_dir,$log_dir,$bed{$line[2]},"&");
        #     push @output,$rest;
        # }
    # }
}

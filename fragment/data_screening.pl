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
            -fd	file_dir"

 unless @ARGV>=1;

my $is_cat;
my $file_path_a;
my $file_path_b;
my $file_path_out;
my $file_type;
my $bed;
my $type;
my $filedir;

Getopt::Long::GetOptions (
    'cat+'  => \$is_cat,
    'fpa=s' => \$file_path_a,
    'fpb=s' => \$file_path_b,
    'fpo=s' => \$file_path_out,
    'bed=s' => \$bed,
    't=s' => \$type,
    'fd=s' => \$filedir,
);

my $basedir = "./";
my @file_list=();
my @dir;
my @sample_list;
my @cat_list;

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
    open SAMPLE, ">./sample_list" or die "Can not create sample_list\n";
    foreach my $file (@dir) {
        if ( $file =~ /[a-z]*R1\.fastq.gz/) {
            push (@file_list , $file);
            syn_sample_list($file);
        }
    }
    my $sample_list=join"", @sample_list;
    print SAMPLE "$sample_list";
    print "sample_list process done!\n";
}

sub syn_sample_list {
    my $name= $_[0];
    if($bed && $type) {
        push @sample_list, "$name\tpe\t$bed\t$type\t$name\t0\t$filedir\n"
    } else {
        die "please input bed ,type and file_output_path";
    }
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

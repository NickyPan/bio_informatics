#!/usr/bin/perl
#########################
#name: WES_auto_processing
#version: 0.0.1
#Author: NickyPan
#Modified By: NickyPan 
#Created time: 02/09/2018 7:28:18
#Last Modified: 02/09/2018 8:12:59
#########################

use strict;
use warnings;
use Getopt::Long;

my $base_dir="./";
my $bed;
Getopt::Long::GetOptions (
    'tn=i' => \$task_num,
);

my @base_dir;
my %family_storage;

opendir (DIR, $base_dir) or die "can't open the directory!";
@base_dir = readdir DIR;
foreach my $file (@base_dir) {
    my @tmp_array;
    map { if($file eq $_) { print "$vv\n"} } @tmp_array;
}

print "family_samples\n";

#!/usr/bin/perl
#########################
#name: watch_50G
#version: 0.0.1
#Author: NickyPan
#Modified By: NickyPan 
#Created time: 02/08/2018 7:34:32
#Last Modified: 02/08/2018 9:14:56
#########################

use strict;
use warnings;

my $basedir = "./";
my @exsited_list;
my @dir_list;
my @dir_only;
my %hash_dir;
my %hash_exsited;

opendir (DIR, $basedir) or die "can't open the directory!";
my @dir = readdir DIR;
foreach my $file (@dir) {
    if ( $file =~/^G/) {
        push @dir_list, $file;
    }
}
close DIR;

if(-e "./watch_50G_list"){
  open GLIST, "<./watch_50G_list" or die "Can not create cat_list\n";
  while(<GLIST>) {
    chomp;
    s/\r$//;
    push @exsited_list, $_;
  }
  close GLIST;

  %hash_dir = map{$_=>1} @dir_list;
  %hash_exsited = map{$_=>1} @exsited_list;
  @dir_only = grep {!$hash_exsited{$_}} @dir_list;
}
print "@dir_only\n";

# open GLIST, ">./watch_50G_list" or die "Can not create cat_list\n";
# my $result=join"\n", @dir_list;
# close GLIST;

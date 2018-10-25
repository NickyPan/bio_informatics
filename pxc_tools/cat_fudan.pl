#!/usr/bin/perl
use strict;
use warnings;
die "Usage: perl $0 name.list bed type out.file > sample_list \n" unless (@ARGV == 4);
open (NAME, "$ARGV[0]") or die "Can not open file $ARGV[0]\n";
my $file_path_a=$ARGV[1];
my $file_path_b=$ARGV[2];
my $file_path_out=$ARGV[3];
my $name;
while (<NAME>) {
	chomp;
	$name = $_;
	print "cat $file_path_a/$name $file_path_b/$name > $file_path_out/$name\necho \"end $name\"\n "
}
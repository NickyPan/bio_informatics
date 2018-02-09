#!/usr/bin/perl
#########################
#name: calculate_stats
#version: 0.1.0
#Author: NickyPan
#Modified By: NickyPan
#Created time: 02/09/2018 9:03:47
#Last Modified: 02/09/2018 11:39:59
#########################

use strict;
use warnings;
use Getopt::Long;
##############usage##############################
die "Usage:
    perl [script] -i [input_depth] -o [output_file] -b [input_bed]

            -i  input: depth file
            -o  output
            -b  input:bed_file"
unless @ARGV>=1;

my $base_dir;
my $bed;
Getopt::Long::GetOptions (
   'i=s' => \$base_dir,
   'b:s' => \$bed,

);

my $summary="$base_dir/target_depth_summary.txt";
open SUM, ">$summary"
     or die "Cannot open file $summary!\n";
open BED, "<$bed"
     or die "Cannot open file $bed\n";

my %bed;
while(<BED>) {
  chomp;
  my @line=split/\t/,$_;
  for (my $i=$line[1];$i<=$line[2];$i++) {

    if(substr($line[0],0,3) ne "chr") {
      $line[0]="chr".$line[0];
    }
    my $pos=$line[0].":".$i;
    $bed{$pos}=0;
  }
}
print "bed_done\n";
my @sites=keys %bed;
my $sites=$#sites+1;
my @dir;
my @re;

my $tt=join"\t",("sample","mean depth","on_target_ratio","target depth","total depth",">=1X",">=4X",">=10X",">=20X",">=30X",">=40X",">=50X",">=100X",">=500X",">=1000",">=5000");
push @re, $tt;

opendir (DIR, $base_dir) or die "can't open the directory!";
@dir = readdir DIR;
foreach my $file (@dir) {
    if ( $file =~ /\.sorted.depth$/) {
        calculate_stats($file);
    }
    print "$file cal_done\n";
}

my $result=join"\n",@re;
print SUM "$result";

sub calculate_stats {
  my $mean_dp=0;
  my $total_dp=0;
  my $dp1=0;
  my $dp4=0;
  my $dp10=0;
  my $dp20=0;
  my $dp30=0;
  my $dp40=0;
  my $dp50=0;
  my $dp100=0;
  my $dp200=0;
  my $dp500=0;
  my $dp1000=0;
  my $dp5000=0;
  my $depth_sum=0;
  my $on_target;
  my $cal_file= $_[0];
  my @sample_name=split('_', $cal_file);

  open DP, "<$base_dir/$cal_file"
      or die "Cannot open file $cal_file!\n";

  while (<DP>) {
    chomp;
    my @ln=split/\t/,$_;
    my $ps=$ln[0].":".$ln[1];
    $depth_sum+=$ln[2];
    if(exists($bed{$ps})) {
      $bed{$ps}=$ln[2];
      $total_dp+=$ln[2];
    if($ln[2]>=1){
      $dp1++;
      if($ln[2]>=4) {
        $dp4++;
        if($ln[2]>=10) {
          $dp10++;
          if($ln[2]>=20) {
            $dp20++;
            if($ln[2]>=30) {
              $dp30++;
              if($ln[2]>=40) {
                $dp40++;
                if($ln[2]>=50) {
                  $dp50++;
                  if($ln[2]>=100) {
                    $dp100++;
                    if($ln[2]>=500) {
                      $dp500++;
                      if($ln[2]>=1000) {
                          $dp1000++;
                          if($ln[2]>=5000) {
                            $dp5000++;
                          }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }##
    }
  }

  $mean_dp=sprintf("%.2f", ($total_dp/$sites));
  $on_target=sprintf("%.2f", ($total_dp/$depth_sum)*100);
  my $dp1_per=sprintf("%.2f", ($dp1/$sites)*100);
  my $dp4_per=sprintf("%.2f", ($dp4/$sites)*100);
  my $dp10_per=sprintf("%.2f", ($dp10/$sites)*100);
  my $dp20_per=sprintf("%.2f", ($dp20/$sites)*100);
  my $dp30_per=sprintf("%.2f", ($dp30/$sites)*100);
  my $dp40_per=sprintf("%.2f", ($dp40/$sites)*100);
  my $dp50_per=sprintf("%.2f", ($dp50/$sites)*100);
  my $dp100_per=sprintf("%.2f", ($dp100/$sites)*100);
  my $dp200_per=sprintf("%.2f", ($dp200/$sites)*100);
  my $dp500_per=sprintf("%.2f", ($dp500/$sites)*100);
  my $dp1000_per=sprintf("%.2f", ($dp1000/$sites)*100);
  my $dp5000_per=sprintf("%.2f", ($dp5000/$sites)*100);

  my $rt=join"\t",($sample_name[0],$mean_dp,$on_target,$total_dp,$depth_sum,$dp1_per,$dp4_per,$dp10_per,$dp20_per,$dp30_per,$dp40_per,$dp50_per,$dp100_per,$dp200_per,$dp500_per,$dp1000_per,$dp5000_per);

  push @re, $rt;

}

# my $out3=join"\n","Sample\t$depth","mean_read_depth_in_target_region\t$mean_dp","bases_covered_at_>=10X\t$dp10_per","bases_covered_at_>=30X\t$dp30_per","bases_covered_at_>=100X\t$dp100_per";
# my $sp="################################################################################";
# my $out=join"\n",$tt,$rt,$sp,$out3,$sp;



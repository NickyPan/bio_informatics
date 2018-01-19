#! /usr/bin/perl -w
use strict;
use Getopt::Long;

##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -f [filter_maf] -d [genedab]

        -i  input:  vcf file
        -o  output"
unless @ARGV>=1;

########################

my $in;
my $out;
my $db;
Getopt::Long::GetOptions (
   'i=s' => \$in,
   'o=s' => \$out

);

open IN, "<$in"
     or die "Cannot open file $in!\n";
open OUT, ">$out"
     or die "Cannot open file $out!\n";

my %gene_dis;
my %eye_dis;
my %rp_dis;
my %fevr_dis;
my %endo_dis;
my %ner_dis;

my @result;

if ($in) {
  acess_eye_panel();
  anno_whpanel();
  my $result=join"\n",@result;
  print OUT "$result";
} else {
  print 'fail'
}

sub acess_eye_panel {

  my $eye_lct=0;
  my $rp_lct=0;
  my $fver_lct=0;

  my $eye_db = '/mnt/workshop/xinchen.pan/pipeline/pxc_tools/wh_db/eye_panel_1801.txt';
  my $rp_db = '/mnt/workshop/xinchen.pan/pipeline/pxc_tools/wh_db/rplca_1801.txt';
  my $fevr_db = '/mnt/workshop/xinchen.pan/pipeline/pxc_tools/wh_db/fevr_1801.txt';

  open eyeDB, "<$eye_db"
       or die "cannot open file $eye_db!\n";
  open rpDB, "<$rp_db"
       or die "cannot open file $rp_db!\n";
  open fverDB, "<$fevr_db"
       or die "cannot open file $fevr_db!\n";

  while(<eyeDB>) {
     chomp;
     s/\r$//;
     $eye_lct++;
     my @var=split/\t/,$_;

     if($eye_lct>1) {

       if(!exists($eye_dis{$var[1]})){
        $eye_dis{$var[0]}=$var[1];

       } else {
         my @genedis=split/\;/,$eye_dis{$var[0]};
         my $gdnum=0;
         for (my $j=0;$j<=$#genedis;$j++) {
           if($genedis[$j] ne $var[1]) {
             $gdnum++;
            } else {
             $gdnum=0;
             last;
            }
         }

         if($gdnum!=0){
           $eye_dis{$var[0]}.=";$var[1]";
         }
       }
     }
  }

  while(<rpDB>) {
     chomp;
     s/\r$//;
     $rp_lct++;
     my @var=split/\t/,$_;

     if($rp_lct>1) {

       if(!exists($rp_dis{$var[1]})){
        $rp_dis{$var[0]}=$var[1];

       } else {
         my @genedis=split/\;/,$rp_dis{$var[0]};
         my $gdnum=0;
         for (my $j=0;$j<=$#genedis;$j++) {
           if($genedis[$j] ne $var[1]) {
             $gdnum++;
            } else {
             $gdnum=0;
             last;
            }
         }

         if($gdnum!=0){
           $rp_dis{$var[0]}.=";$var[1]";
         }
       }
     }
  }

  while(<fverDB>) {
     chomp;
     s/\r$//;
     $fver_lct++;
     my @var=split/\t/,$_;

     if($fver_lct>1) {

       if(!exists($fevr_dis{$var[1]})){
        $fevr_dis{$var[0]}=$var[1];

       } else {
         my @genedis=split/\;/,$fevr_dis{$var[0]};
         my $gdnum=0;
         for (my $j=0;$j<=$#genedis;$j++) {
           if($genedis[$j] ne $var[1]) {
             $gdnum++;
            } else {
             $gdnum=0;
             last;
            }
         }

         if($gdnum!=0){
           $fevr_dis{$var[0]}.=";$var[1]";
         }
       }
     }
  }
}

sub acess_endocrine_panel {

}

sub acess_nervous_panel {

}

sub anno_whpanel {
  my $line_count=0;
  my $line;
  my $eye_length = keys %eye_dis;
  my $rp_length = keys %rp_dis;
  my $fevr_length = keys %fevr_dis;
  my $endo_length = keys %endo_dis;
  my $ner_length = keys %ner_dis;
  while(<IN>) {
   chomp;
   $line=$_;
   $line_count++;
   if($line_count>1) {
    my @line=split/\t/,$line;
    my @gene=split/,/,$line[6];

    if($eye_length>0) {
      my @eye_dis;
      for(my $i=0;$i<=$#gene;$i++) {
        if(exists($eye_dis{$gene[$i]}) and $gene[$i]ne".") {
          push @eye_dis,$eye_dis{$gene[$i]};

        }else {
          push @eye_dis,".";
        }
      }
      $line.="\t".(join"|",@eye_dis);
    }

    if($rp_length>0) {
      my @rp_dis;
      for(my $i=0;$i<=$#gene;$i++) {
        if(exists($rp_dis{$gene[$i]}) and $gene[$i]ne".") {
          push @rp_dis,$rp_dis{$gene[$i]};

        }else {
          push @rp_dis,".";
        }
      }
      $line.="\t".(join"|",@rp_dis);
    }

    if($fevr_length>0) {
      my @fevr_dis;
      for(my $i=0;$i<=$#gene;$i++) {
        if(exists($fevr_dis{$gene[$i]}) and $gene[$i]ne".") {
          push @fevr_dis,$fevr_dis{$gene[$i]};

        }else {
          push @fevr_dis,".";
        }
      }
      $line.="\t".(join"|",@fevr_dis);
    }

    if($endo_length>0) {
      my @endo_dis;
      for(my $i=0;$i<=$#gene;$i++) {
        if(exists($endo_dis{$gene[$i]}) and $gene[$i]ne".") {
          push @endo_dis,$endo_dis{$gene[$i]};

        }else {
          push @endo_dis,".";
        }
      }
      $line.="\t".(join"|",@endo_dis);
    }

    if($ner_length>0) {
      my @ner_dis;
      for(my $i=0;$i<=$#gene;$i++) {
        if(exists($ner_dis{$gene[$i]}) and $gene[$i]ne".") {
          push @ner_dis,$ner_dis{$gene[$i]};

        }else {
          push @ner_dis,".";
        }
      }
      $line.="\t".(join"|",@ner_dis);
    }

    push @result,$line;

   } else {
     if($eye_length>0) {
      push @result,join("\t",($line, 'eye_panel', 'RP/LCA', 'FEVR'));
     }
     if($endo_length>0) {
      push @result,join("\t",($line, 'endo_panel'));
     }
     if($ner_length>0) {
      push @result,join("\t",($line, 'nerv_panel'));
     }
   }
  }
}

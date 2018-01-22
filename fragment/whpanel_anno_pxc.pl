#! /usr/bin/perl -w
use strict;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);
##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -f [filter_maf] -d [genedab]

        -i  input:  vcf file
        -o  output
        -f  family index: father mother proband"
unless @ARGV>=1;

########################

my $in;
my $out;
my $db;
my @family_index;
my $eye;
my $endo;
my $nerv;
Getopt::Long::GetOptions (
   'i=s' => \$in,
   'o=s' => \$out,
   'f=i' => \@family_index,
   'eye+'  => \$eye,
   'endo+'  => \$endo,
   'nerv+'  => \$nerv,
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
my $fa_index;
my $mo_index;
my $pro_index;
my $IR_Ref="000000, 000100, 000101, 001101, 010000, 010100, 010001, 010101, 011101, 010111, 011111, 110001, 110101, 110111, 111111";
my $novo_Ref="001100, 000001, 000011, 000111, 001111, 011100, 010011, 110000, 110100, 111100, 111101, 110011";

my @result;

if ($#family_index>0) {
    $fa_index = $family_index[0];
    $mo_index = $family_index[1];
    $pro_index = $family_index[2];
} else {
    die "please input family index: father mother proband\n";
}

if ($in) {
  if($eye) {
    acess_eye_panel();
  }
  # if($endo) {
  #   acess_eye_panel();
  # }
  # if($nerv) {
  #   acess_eye_panel();
  # }
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
  my $endo_lct=0;
  my $endo_db = '/mnt/workshop/xinchen.pan/pipeline/pxc_tools/wh_db/endocrine_panel_1801.txt';

  open endoDB, "<$endo_db"
       or die "cannot open file $endo_db!\n";

  while(<endoDB>) {
     chomp;
     s/\r$//;
     $endo_lct++;
     my @var=split/\t/,$_;

     if($endo_lct>1) {

       if(!exists($endo_dis{$var[1]})){
        $endo_dis{$var[0]}=$var[1];

       } else {
         my @genedis=split/\;/,$endo_dis{$var[0]};
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
           $endo_dis{$var[0]}.=";$var[1]";
         }
       }
     }
  }
}

sub acess_nervous_panel {
  my $ner_lct=0;
  my $ner_db = '/mnt/workshop/xinchen.pan/pipeline/pxc_tools/wh_db/nervous_panel_1801.txt';

  open nerDB, "<$ner_db"
       or die "cannot open file $ner_db!\n";

  while(<nerDB>) {
     chomp;
     s/\r$//;
     $ner_lct++;
     my @var=split/\t/,$_;

     if($ner_lct>1) {

       if(!exists($ner_dis{$var[1]})){
        $ner_dis{$var[0]}=$var[1];

       } else {
         my @genedis=split/\;/,$ner_dis{$var[0]};
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
           $ner_dis{$var[0]}.=";$var[1]";
         }
       }
     }
  }
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
    my $fa_line=substr($line[$fa_index],0,1) . substr($line[$fa_index],2,1);
    my $mo_line=substr($line[$mo_index],0,1) . substr($line[$mo_index],2,1);
    my $pro_line=substr($line[$pro_index],0,1) . substr($line[$pro_index],2,1);

    # check Inheritance
    my $IR_type;
    if (looks_like_number($fa_line) && looks_like_number($mo_line) && looks_like_number($pro_line)) {
        $IR_type=$fa_line . $mo_line . $pro_line;
        my $is_IR=index $IR_Ref, $IR_type;
        my $is_novo=index $novo_Ref, $IR_type;
        if($is_novo>=0){
            $line.="\tde novo";
        } elsif($is_IR>=0) {
            $line.="\tIR";
        } else {
            $line.="\tUnknow";
        }
    } else {
        $line.="\t.";
    }

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
    if($#family_index>0) {
      $line.="\tInheritance";
    }
    if($eye_length>0) {
      $line.="\teye_panel";
      $line.="\tRP/LCA";
      $line.="\tFEVR";
    }
    if($endo_length>0) {
      $line.="\tendo_panel";
    }
    if($ner_length>0) {
      $line.="\tnerv_panel";
    }
    push @result, $line;
   }
  }
}

#! /usr/bin/perl -w
use strict;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);
use Math::Combinatorics;
use Data::Dumper;
##############usage##############################
die "Usage:
    perl [script] -i [input_txt] -o [output_file] -f [filter_maf] -d [genedab]

        -i  input:  txt file
        -f  family index: father mother proband
        -maf  filter_maf
        -d  genedb"
unless @ARGV>=1;

########################

my $in;
my $out;
my $maf;
my $db;
my @family_index;
my $eye;
my $endo;
my $nerv;
Getopt::Long::GetOptions (
   'i=s' => \$in,
   'f=i' => \@family_index,
   'eye+'  => \$eye,
   'endo+'  => \$endo,
   'nerv+'  => \$nerv,
   'maf:f' => \$maf,
   'd:s' => \$db,
);

open IN, "<$in"
     or die "Cannot open file $in!\n";
$in=~ m/.anno.hg19_multianno.txt/;
my $file_name=$`;
$out=$file_name.".anno.hg19_multianno.wh_anno.txt";

open OUT, ">$out"
     or die "Cannot open file $out!\n";

my $fa_index;
my $mo_index;
my $pro_index;
my $IR_type;
my @IR_array;
my %combine_array;
my $IR_Ref="000000, 000100, 000101, 001101, 010000, 010100, 010001, 010101, 011101, 010111, 011111, 110001, 110101, 110111, 111111";
my $novo_Ref="001100, 000001, 000011, 000111, 001111, 011100, 010011, 110000, 110100, 111100, 111101, 110011";
my @secondary_gene=("Gene","BRCA1","BRCA2","TP53","STK11","MLH1","MSH2","MSH6","PMS2","APC","MUTYH","VHL","MEN1","RET","PTEN","RB1","SDHD","SDHAF2","SDHC","SDHB","TSC1","TSC2","WT1","NF2","COL3A1","FBN1","TGFBR1","TGFBR2","SMAD3","ACTA2","MYLK","MYH11","MYBPC3","MYH7","TNNT2","TNNI3","TPM1","MYL3","ACTC1","PRKAG2","GLA","MYL2","LMNA","RYR2","PKP2","DSP","DSC2","TMEM43","DSG2","KCNQ1","KCNH2","SCN5A","LDLR","APOB","PCSK9","RYR1","CACNA1S","BMPR1A","SMAD4","ATP7B","OTC");

my @result;

my $is_IRanno=0;
my $is_Relation=0;

if (scalar(@family_index)>2) {
    $fa_index = $family_index[0];
    $mo_index = $family_index[1];
    $pro_index = $family_index[2];
    $is_IRanno=1;
    $is_Relation=1;
} elsif(scalar(@family_index)>1 && scalar(@family_index)<3) {
    $is_Relation=1;
} else {
    print "no Inheritance annotate\n";
}

if ($in) {
  acess_header();
  acess_genedb();
  if($eye) {
    acess_eye_panel();
  }
  if($endo) {
    acess_eye_panel();
  }
  if($nerv) {
    acess_eye_panel();
  }
  anno_whpanel();
  if($is_Relation) {
    cal_relation_per();
  }
  my $result=join"\n",@result;
  print OUT "$result";
} else {
  print 'fail'
}

my %chr_pos_dis;
my %gene_dis;
my %mut_dis;
sub acess_genedb {
  open DB, "<$db"
     or die "cannot open file $db!\n";

  my $db_lct=0;

  while(<DB>) {
    chomp;
    s/\r$//;
    $db_lct++;
    my @var=split/\t/,$_;
    my $chr_pos="chr".$var[0].":".$var[1];
    my $mut=$chr_pos.":".$var[3]."-".$var[4];

    if($db_lct>1) {

      if(!exists($chr_pos_dis{$chr_pos}) ){
        $chr_pos_dis{$chr_pos}=$chr_pos."|".$var[5]."|".$var[6]."|".$var[7]."|".$var[9]."|".$var[10]."|".$var[11]."|".$var[12]."|".$var[13];
      } else {
        my @chrposdis=split/\;/,$chr_pos_dis{$chr_pos};

        for(my $i=0;$i<=$#chrposdis;$i++) {
          if($chrposdis[$i] ne $chr_pos."|".$var[5]."|".$var[6]."|".$var[7]."|".$var[9]."|".$var[10]."|".$var[11]."|".$var[12]."|".$var[13]){
            $chr_pos_dis{$chr_pos}.=";".$chr_pos."|".$var[5]."|".$var[6]."|".$var[7]."|".$var[9]."|".$var[10]."|".$var[11]."|".$var[12]."|".$var[13];
          }
        }
      }

      if(!exists($gene_dis{$var[9]})){
        $gene_dis{$var[9]}=$var[13];

      } else {
        my @genedis=split/\;/,$gene_dis{$var[9]};
        # print "@genedis\n";
        my $gdnum=0;
        for (my $j=0;$j<=$#genedis;$j++) {
          if($genedis[$j] ne $var[13]) {
            $gdnum++;
            } else {
            $gdnum=0;
            last;
            }
        }

        if($gdnum!=0){
          $gene_dis{$var[9]}.=";$var[13]";
        }

      }

      if(!exists($mut_dis{$mut})){
        $mut_dis{$mut}=$mut."|".$var[5]."|".$var[6]."|".$var[7]."|".$var[9]."|".$var[10]."|".$var[11]."|".$var[12]."|".$var[13];
      }else {
        $mut_dis{$mut}.=";".$mut."|".$var[5]."|".$var[6]."|".$var[7]."|".$var[9]."|".$var[10]."|".$var[11]."|".$var[12]."|".$var[13];
      }
    }
  }
}

my %eye_dis;
my %rp_dis;
my %fevr_dis;
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

my %endo_dis;
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

my %ner_dis;
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

my $header;
my @headin;
my @header_old;
my $header_fixed;
my $line_old;
sub acess_header {
  open RAW_VCF, "<$file_name.raw.vcf"
       or die "cannot open file $file_name.raw.vcf!\n";
  while (<RAW_VCF>) {
    if ($_ =~ /\#CHROM/){
      chomp ;
      $header = $_;
      $header =~ s/\#//;
      @headin = split (/\t/,$header);
    }
  }
  unshift (@headin,("C1", "C2"));
  $line_old= $_[0];
  chomp $line_old;
  @header_old=split (/\t/, $line_old);
  push @header_old, @headin;
  $header_fixed=join ("\t", @header_old);
  print "fixing_header done!\n";
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

    #fix header
    if ($line_count == 0) {
      acess_header($line);
      $line=$header_fixed;
    }
    $line_count++;

    #start annovar
    if($line_count>1) {
      my @line=split/\t/,$line;
      my @gene=split/,/,$line[6];
      my $mutation=$line[0].":$line[1]".":$line[3]"."-$line[4]";
      my $chr_site=$line[0].":$line[1]";

      if ( $is_IRanno ) {
        my $fa_line=substr($line[$fa_index],0,1) . substr($line[$fa_index],2,1);
        my $mo_line=substr($line[$mo_index],0,1) . substr($line[$mo_index],2,1);
        my $pro_line=substr($line[$pro_index],0,1) . substr($line[$pro_index],2,1);
        $IR_type=$fa_line . $mo_line . $pro_line;
      }

      #check the parent-child relation
      if ($is_Relation) {
        if(looks_like_number($line[24]) && ($line[24] > 0.45 && $line[24] < 0.55)) {
          if ( $is_IRanno ) {
            push (@IR_array, $IR_type);
          }
          my $combinat = Math::Combinatorics->new(count => 2, data => [@family_index]);
          while(my @combo = $combinat->next_combination){
            my $combin_type = substr($line[$combo[0]],0,1) . substr($line[$combo[0]],2,1) . substr($line[$combo[1]],0,1) . substr($line[$combo[1]],2,1);
            my $combin_title = "$combo[0]-$combo[1]";
            push( @{ $combine_array{$combin_title} }, $combin_type);
          }
        }
      }

      #start filter and anotate
      if(($line[10] eq "." or $line[10]*1<$maf) and ($line[11] eq "." or $line[11]*1<$maf) and ($line[21] eq "." or $line[21]*1<$maf) and ($line[24] eq "." or $line[24]*1<$maf)  and($line[29] eq "." or $line[29]*1<$maf) ) {

        if(!exists($mut_dis{$mutation})) {
            push (@line, ".");
        } else {
            push (@line, $mut_dis{$mutation});
        }
        if(!exists($chr_pos_dis{$chr_site})) {
            push (@line, ".");
        } else {
            push (@line, $chr_pos_dis{$chr_site});
        }
        my @gene_dis;
        for(my $i=0;$i<=$#gene;$i++) {
          if(!exists($gene_dis{$gene[$i]}) and $gene[$i]ne".") {
            push @gene_dis,".";
          } elsif(exists($gene_dis{$gene[$i]}) and $gene[$i]ne".") {
            push @gene_dis,$gene_dis{$gene[$i]};

          }else {
            push @gene_dis,".";
          }
        }
        push (@line, (join".",@gene_dis));

        my $pred_high=0;
        my $pred_low=0;
        my @line_pred=(33,36,42,45,48,51,54,59,62,64,73);
        foreach my $pred (@line_pred){
            if ($line[$pred] && $line[$pred] ne ".") {
              if ($line[$pred] eq "D" or $line[$pred] eq "A" or $line[$pred] eq "H") {
                $pred_high++;
              } else {
                $pred_low++;
              }
            }
        }
        if($pred_high>0 or $pred_low>0) {
          my $pred_total=$pred_high + $pred_low;
          my $pred_mean=sprintf("%.2f", ($pred_high/$pred_total)*100);
          push (@line, "$pred_mean%","$pred_high|$pred_total");
        } else {
          push (@line, ".", ".");
        }

        # check Inheritance
        if ( $is_IRanno ) {
          if (looks_like_number($IR_type)) {
              my $is_IR=index $IR_Ref, $IR_type;
              my $is_novo=index $novo_Ref, $IR_type;
              if($is_novo>=0){
                  push (@line, "de novo");
              } elsif($is_IR>=0) {
                  push (@line, "IR");
              } else {
                  push (@line, "Unknow");
              }
          } else {
              push (@line, ".");
          }
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
          push (@line, (join".",@eye_dis));
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
          push (@line, (join".",@rp_dis));
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
          push (@line, (join".",@fevr_dis));
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
          push (@line, (join".",@endo_dis));
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
          push (@line, (join".",@ner_dis));
        }

        foreach my $gene_name(@gene){
          if (grep {$_ eq $gene_name} @secondary_gene) {
            $gene_name.="*";
            print "$gene_name\n";
          }
        }
        $line[6]=join",", @gene;

        my $new_line=join("\t",@line);
        push @result,$new_line;

      }

    } else {
      $line.="\tmut_dis\tsite_dis\tgene_dis\tpred_per\tpred_stats";
      if($is_IRanno) {
        $line.="\tInheritance";
      }
      if($eye) {
        $line.="\teye_panel";
        $line.="\tRP/LCA";
        $line.="\tFEVR";
      }
      if($endo) {
        $line.="\tendo_panel";
      }
      if($nerv) {
        $line.="\tnerv_panel";
      }
      push @result, $line;
    }
  }
}

sub cal_relation_per {
  my $line_title = $result[0];
  chomp $line_title;
  my @line_name = split (/\t/, $line_title);
  if ($is_IRanno) {
    my $IR_ok=0;
    my $IR_reject=0;
    for( my $i = 0; $i < scalar(@IR_array); $i++ ){
      if (looks_like_number($IR_array[$i])) {
        if ($IR_array[$i] == "000000" or $IR_array[$i] == "000100" or $IR_array[$i] == "000101" or $IR_array[$i] == "001101" or $IR_array[$i] == "010000" or $IR_array[$i] == "010100" or $IR_array[$i] == "010001" or $IR_array[$i] == "010101" or $IR_array[$i] == "011101" or $IR_array[$i] == "010111" or $IR_array[$i] == "011111" or $IR_array[$i] == "110001" or $IR_array[$i] == "110101" or $IR_array[$i] == "110111" or $IR_array[$i] == "111111") {
          $IR_ok++;
        } elsif ($IR_array[$i] == "001100" or $IR_array[$i] == "000001" or $IR_array[$i] == "000011" or $IR_array[$i] == "000111" or $IR_array[$i] == "001111" or $IR_array[$i] == "011100" or $IR_array[$i] == "010011" or $IR_array[$i] == "110000" or $IR_array[$i] == "110100" or $IR_array[$i] == "111100" or $IR_array[$i] == "111101" or $IR_array[$i] == "110011" ) {
          $IR_reject++
        }
      }
    }
    my $IR_per=sprintf("%.2f", ($IR_ok/($IR_ok + $IR_reject))*100);
    $result[0].="\tP-C($IR_per%)";
  }
  my @combine_name = keys %combine_array;
  for( my $i = 0; $i < scalar(@combine_name); $i++ ){
    my $combine_ok=0;
    my $combine_reject=0;
    my @combine_text=values $combine_array{$combine_name[$i]};
    for( my $j = 0; $j < scalar(@combine_text); $j++ ){
      if (looks_like_number($combine_text[$j])) {
        if ($combine_text[$j] == "0000" or $combine_text[$j] == "0001" or $combine_text[$j] == "0100" or $combine_text[$j] == "0101" or $combine_text[$j] == "0111" or $combine_text[$j] == "1101" or $combine_text[$j] == "1111" ) {
          $combine_ok++;
        } elsif ( $combine_text[$j] == "1100" or $combine_text[$j] == "0011" ) {
          $combine_reject++;
        }
      }
    }
    my $combine_per=sprintf("%.2f", ($combine_ok/($combine_ok + $combine_reject))*100);
    my $name1=substr($combine_name[$i],0,3);
    my $name2=substr($combine_name[$i],4,3);
    $result[0].="\t$line_name[$name1]-$line_name[$name2]($combine_per%)";
  }
}

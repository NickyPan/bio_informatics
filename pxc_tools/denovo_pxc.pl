#! /usr/bin/perl -w
use strict;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);
##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -f [filter_maf] -d [genedab]

        -i  input:  vcf file
        -o  output
        -f family index: father mother proband"
unless @ARGV>=1;

########################

my $in;
my $out;
my @family_index;
Getopt::Long::GetOptions (
   'i=s' => \$in,
   'o=s' => \$out,
   'f=i' => \@family_index
);

my $line_count=0;
my @result;
my $line;
my $fa_index;
my $mo_index;
my $pro_index;
my $IR_Ref="000000, 000100, 000101, 001101, 010000, 010100, 010001, 010101, 011101, 010111, 011111, 110001, 110101, 110111, 111111";
my $novo_Ref="001100, 000001, 000011, 000111, 001111, 011100, 010011, 110000, 110100, 111100, 111101, 110011";

if ($#family_index>0) {
    $fa_index = $family_index[0];
    $mo_index = $family_index[1];
    $pro_index = $family_index[2];
} else {
    die "please input family index: father mother proband\n";
}

open IN, "<$in"
     or die "Cannot open file $in!\n";
open OUT, ">$out"
     or die "Cannot open file $out!\n";

while(<IN>) {
 chomp;
 $line=$_;
 $line_count++;
 if($line_count>1) {

    my @line=split/\t/,$line;
    my $fa_line=substr($line[$fa_index],0,1) . substr($line[$fa_index],2,1);
    my $mo_line=substr($line[$mo_index],0,1) . substr($line[$mo_index],2,1);
    my $pro_line=substr($line[$pro_index],0,1) . substr($line[$pro_index],2,1);

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
    push @result,$line;
 } else {
  push  @result,join("\t",($line,"Inheritance"));
 }
}
my $result=join"\n",@result;

print OUT "$result";

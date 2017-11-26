#!/usr/bin/perl
#-- Perl script to generate test input for Banker's Algorithm
#-- Brandon Cercone
use strict;
use warnings;

my $tmp;
my @max;
my @alloc;
my @avail;
my @request;
my ($numP, $numR) = @ARGV;
#-- Check for params
if (not defined $numP or not defined $numR) {die "max numP and numR\n"; }

#-- Randomly choose process to be first in sequence
my $pid = int(rand($numP));
#-- Generate available resource vector
generate_avail(\@avail,1,$numR);
#-- Generate Max Matrix
generate_max_matrix(\@max,\@avail,$numP,$numR,$pid);
#-- Generate Alloc Matrix
generate_alloc_matrix(\@max,\@alloc,\@avail,$numP,$numR,$pid);
#-- Generate request vector
#generate_alloc_matrix(\@avail,\@request,1,$numR);

#-- Print
printf "%d\n%d\n", $numP, $numR;
#print_matrix(\@request,1,$numR);
print_matrix(\@avail,1,$numR);
print_matrix(\@max,$numP,$numR);
print_matrix(\@alloc,$numP,$numR);

sub generate_avail {
    for (my $p = 0; $p < $_[1]; $p++){
        for (my $r = 0; $r < $_[2]; $r++){
            $_[0][$p][$r] = int(rand(100)) + 10;
        }
    }
}
#-- Generate max matrix
sub generate_max_matrix {
    for (my $p = 0; $p < $_[2]; $p++){
        if ($p eq $_[4]){
            for (my $r = 0; $r < $_[3]; $r++){
                $tmp = int(rand(100)) + 20;
                $_[0][$p][$r] = ($tmp > $_[1][0][$r]) ? $tmp : $_[1][0][$r];
                #$_[0][$p][$r] = $_[1][0][$r] + 10 ;
            }
        }
        else{
            for (my $r = 0; $r < $_[3]; $r++){
                $_[0][$p][$r] = int(rand(100));
            }
        }
    }
}
#-- Generate allocation matrix by using the values from need
#-- as an upperbound on the rand
sub generate_alloc_matrix {
    for (my $p = 0; $p < $_[3]; $p++){
        if ($p eq $_[5]){
            for (my $r = 0; $r < $_[4]; $r++){
                $_[1][$p][$r] = $_[0][$p][$r] - $_[2][0][$r];
            }
        }
        else{
            for (my $r = 0; $r < $_[4]; $r++){
                $_[1][$p][$r] = int(rand($_[0][$p][$r]));
            }
        }
    }
}
#-- Print comma separated matrix
sub print_matrix {
    for (my $p = 0; $p < $_[1]; $p++){
        for (my $r = 0; $r < $_[2]; $r++){
            printf ( $r == $_[2] - 1 ? "$_[0][$p][$r]\n" : "$_[0][$p][$r],");
        }
    }
}

#!/usr/bin/perl
#-- Perl script to generate test input for Banker's Algorithm
#-- Brandon Cercone
use strict;
use warnings;

my @max;
my @alloc;
my @avail;
my ($numP, $numR) = @ARGV;
#-- Check for params
if (not defined $numP or not defined $numR) {die "max numP and numR\n"; }

#-- Print
printf "%d\n%d\n", $numP, $numR;
#-- Generate available resource vector
generate_avail(\@avail,$numR);
print_vector(\@avail,$numR);
#-- Generate Matrices
generate_matrices(\@avail,\@max,\@alloc,$numP,$numR);

print_matrix(\@max,$numP,$numR);
print_matrix(\@alloc,$numP,$numR);

sub generate_avail {
        for (my $r = 0; $r < $_[1]; $r++){
                $_[0][$r] = int(rand(25));
        }
}
#-- Generate max matrix
sub generate_matrices {
        my @randarr;
        for (my $p = 0; $p < $_[3]; $p++){
                $randarr[$p] = $p;
        }
        shuf(\@randarr);
        for (my $p = 0; $p < $_[3]; $p++){
                my $index = $randarr[$p];
                for (my $r = 0; $r < $_[4]; $r++){
                        $_[1][$index][$r] = int(rand(10)) + $_[0][$r];
                        $_[2][$index][$r] = $_[1][$index][$r] - $_[0][$r];
                        $_[0][$r] += $_[2][$index][$r];
                }
        }
}
#-- Randomize array
sub shuf {
        my $randarr = shift;
        my $i = @$randarr;
        while($i--){
                my $j = int rand ($i+1);
                @$randarr[$i,$j] = @$randarr[$j,$i];
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
#-- Print comma separated vector
sub print_vector {
        for (my $p = 0; $p < $_[1]; $p++){
                printf ( $p == $_[1] - 1 ? "$_[0][$p]\n" : "$_[0][$p],");
        }
}

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

#-- Generate Max Matrix
generate_matrix(\@max,$numP,$numR);
#-- Generate Alloc Matrix
generate_alloc_matrix(\@max,\@alloc,$numP,$numR);
#-- Generate available resource vector
#generate_matrix(\@avail,1,$numR);
generate_avail(\@avail,1,$numR);
#-- Generate request vector
generate_alloc_matrix(\@avail,\@request,1,$numR);

#-- Print
printf "%d\n%d\n", $numP, $numR;
print_matrix(\@request,1,$numR);
print_matrix(\@avail,1,$numR);
print_matrix(\@max,$numP,$numR);
print_matrix(\@alloc,$numP,$numR);

sub generate_avail {
        for (my $p = 0; $p < $_[1]; $p++){
                for (my $r = 0; $r < $_[2]; $r++){
                        $_[0][$p][$r] = int(rand(100) + 10);
                }
        }
}
#-- Randomly fill matrix
sub generate_matrix {
        for (my $p = 0; $p < $_[1]; $p++){
                for (my $r = 0; $r < $_[2]; $r++){
                        $tmp = int(rand(50));
                        $_[0][$p][$r] = $tmp;
                }
        }
}
#-- Generate allocation matrix by using the values from need
#-- as an upperbound on the rand
sub generate_alloc_matrix {
        for (my $p = 0; $p < $_[2]; $p++){
                for (my $r = 0; $r < $_[3]; $r++){
                        $tmp = int(rand($_[0][$p][$r] *.75 ));
                        $_[1][$p][$r] = $tmp;
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

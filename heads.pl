#!/usr/bin/perl
# made by: KorG
use strict;
use warnings;

$ENV{PATH} = "/usr/bin:/usr/local/bin";
my %commits;

for my $commit (
   map { substr $_, 0, 40 } grep /\scommit\s/,
   `git cat-file --batch-all-objects --batch-check`
) {
   push @{ $commits{$commit} }, ();
   push @{ $commits{$_} }, $commit for map { substr $_, 7, 40 }
   grep /^parent/, `git cat-file -p $commit`;
}

printf "HEAD: $_\n" for sort grep { 0 == @{ $commits{$_} } } keys %commits;

# use Data::Dumper;
# print Dumper \%commits;

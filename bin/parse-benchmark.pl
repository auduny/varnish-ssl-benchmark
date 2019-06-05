#!/usr/bin/perl

my @data;
my $type,$time_spent,$reqs,$bw;
print "|what\t|time\t|reqs\t|bw\t|\n";
print "|-----|---|---|---|\n";
while(<STDIN>) {
    if (/(Client.*)/) {
        $type = $1;
    } elsif (/finished in ([\d\.ms]+), ([\d\.]+) req\/s, ([\d\.GMB]+)\/s/) {
        $time_spent=$1;
        $reqs=$2;
        $bw=$3;
    } elsif (/0 failed/) {
        push @data, { type => $type, time_spent => $time_spent, reqs => $reqs, bw => $bw };
    }
}

my @sorted = sort { $b->{reqs} <=> $a->{reqs} } @data;
for $line (@sorted) {
   print "|$line->{type}|$line->{time_spent}|$line->{reqs}|$line->{bw}|\n"
}


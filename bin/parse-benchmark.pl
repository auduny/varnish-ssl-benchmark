#!/usr/bin/perl

my $type,$time_spent,$reqs,$bw;
print "|what\t|time\t|reqs\t|bw\t|\n";
print "------------------\n";
while(<STDIN>) {
    if (/(Client.*)/) {
        $type = $1;
    } elsif (/finished in ([\d\.]+)s, ([\d\.]+) req\/s, ([\d\.]+)MB\/s/) {
        $time_spent=$1;
        $reqs=$2;
        $bw=$3;
    } elsif (/0 failed/) {
        print "|$type|$time_spent|$reqs|$bw|\n"
    }
}
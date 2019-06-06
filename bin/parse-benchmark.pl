#!/usr/bin/perl

my @data;
my $type,$time_spent,$reqs,$bw;
print "|what\t|time\t|reqs\t|bw\t|request|connect|1stbyte|savings|\n";
print "|-----|---|---|---|---|---|----|---|----|\n";
while(<STDIN>) {
    if (/(Client.*)/) {
        $type = $1;
    } elsif (/finished in ([\d\.ms]+), ([\d\.]+) req\/s, ([\d\.GMB]+)\/s/) {
        $time_spent=$1;
        $reqs=$2;
        $bw=$3;
    } elsif (/time for request:\s+([\d\.ms]+)\s+([\d\.ms]+)\s+([\d\.ms]+)\s+([\d\.ms]+)\s+([\d\.\%]+)/) {
        $time_for_request_mean=$3;
        $time_for_request_sd=$4
    } elsif (/time for connect:\s+([\d\.ms]+)\s+([\d\.ms]+)\s+([\d\.ms]+)\s+([\d\.ms]+)\s+([\d\.\%]+)/) {
        $time_for_connect_mean=$3;
        $time_for_connect_sd=$4;
    } elsif (/time to 1st byte:\s+([\d\.ms]+)\s+([\d\.ms]+)\s+([\d\.ms]+)\s+([\d\.ms]+)\s+([\d\.\%]+)/) {
        $time_to_1st_byte_mean=$3;
        $time_to_1st_byte_sd=$4;
    } elsif(/headers \(space savings ([\d\.\%]+)/) {
        $space_savings=$1;
    } elsif (/0 failed/) {
        push @data, { type => $type, time_spent => $time_spent, reqs => $reqs, bw => $bw, time_for_request_mean => $time_for_request_mean, time_for_connect_mean => $time_for_connect_mean, time_to_1st_byte_mean => $time_to_1st_byte_mean, space_savings => $space_savings };
    }
}

my @sorted = sort { $b->{reqs} <=> $a->{reqs} } @data;
for $line (@sorted) {
   print "|$line->{type}|$line->{time_spent}|$line->{reqs}|$line->{bw}|$line->{time_for_request_mean}|$line->{time_for_connect_mean}|$line->{time_to_1st_byte_mean}|$line->{space_savings}|\n"
}


#!/usr/bin/perl

my @data;
my $type,$time_spent,$reqs,$bw;

while(<STDIN>) {
    if (/(Client.*)/) {
        $type = $1;
        $type =~ s/Client->//g;
        $type =~ s/ on port (\d+)//;
        $port = $1;
    } elsif (/finished in ([\d\.ms]+), ([\d\.]+) req\/s, ([\d\.GMB]+)\/s/) {
        $time_spent=$1;
        $reqs=$2;
        $bwtemp=$3;
        $bwtemp =~ /([\d\.]+)(\w+)/;
         $bw = $1*8;
        $postfix = $2;
        $postfix =~ s/B/b/g;
       
        $bw = "$bw$postfix/s";
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
    } elsif (/(\d+) failed/) {
        $failed=$1;
    } elsif (/^req\/s/) {
        push @data, { port => $port, type => $type, time_spent => $time_spent, reqs => $reqs, bw => $bw, time_for_request_mean => $time_for_request_mean, time_for_connect_mean => $time_for_connect_mean, time_to_1st_byte_mean => $time_to_1st_byte_mean, space_savings => $space_savings };
    }
}

my @sorted = sort { $b->{reqs} <=> $a->{reqs} } @data;
my $rank=0;
print "|Nr|Port|What\t|Time\t|REQs\t|BW\t|Request|Connect|1stbyte|Savings|\n";
print "|---|---|---|---|---|---|---|---|---|---|\n";
for $line (@sorted) {
   $rank++;
   print "|$rank|$line->{port}|$line->{type}|$line->{time_spent}|$line->{reqs}|$line->{bw}|$line->{time_for_request_mean}|$line->{time_for_connect_mean}|$line->{time_to_1st_byte_mean}|$line->{space_savings}|\n"
}


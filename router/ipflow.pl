#!/usr/bin/perl -w
# Date:2009-03-12
# Author:HyphenWang
# Version:1.0
use strict;
my $IPTABLES_CMD="iptables -v -n -x -L FORWARD";
my $SEC="30";
my $ZERO="1";
my (%first_input,%first_output);
my (%second_input,%second_output);
my %ban_ip;

sub get_ipflow {
  my ($ip_input,$ip_output)=@_;
  for my $line (`$IPTABLES_CMD`) {
    my @columns = split(/\s+/,$line);
    $ip_input->{$columns[-1]}=$columns[2] if ($columns[3] eq "ACCEPT" and $columns[-1] =~ m/192\.168\.2\.\d+/);
    $ip_output->{$columns[-2]}=$columns[2] if ($columns[3] eq "ACCEPT" and $columns[-2] =~ m/192\.168\.2\.\d+/);
    $ban_ip{$columns[-1]}=1 if ($columns[3] eq "DROP" and $columns[-1] =~ m/192\.168\.2\.\d+/);
    $ban_ip{$columns[-2]}=1 if ($columns[3] eq "DROP" and $columns[-2] =~ m/192\.168\.2\.\d+/);
  }
}
get_ipflow(\%first_input,\%first_output);
sleep $SEC;
get_ipflow(\%second_input,\%second_output);
print "Now is ".localtime()."\n";
print "-"x53,"\n";
print "IP Address\t\tIn Flow Rate\tOut Flow Rate\n";
for (keys %first_input) {
  if ($ZERO != 1) {
  	if (defined $second_input{$_} and defined $second_output{$_} and int(($second_input{$_}-$first_input{$_})/1024/$SEC) == 0) {
      next;
    }
  }
  if (defined $second_input{$_} and defined $second_output{$_}) {
  printf ("%s\t\t%.f KByte/s\t%.f KByte/s\n",$_,($second_input{$_}-$first_input{$_})/1024/$SEC,($second_output{$_}-$first_output{$_})/1024/$SEC);
  }
}
print "-"x53,"\n";
print "Banned IP Address:\n";
for (keys %ban_ip) {
  print "$_\n";
}

#!/usr/bin/perl

use warnings;
use strict;

my $list_command   = 'dpkg --get-selections | grep install | grep linux-image | cut -f1';
my $victim_command = 'dpkg --get-selections | grep install | grep linux | grep %s | cut -f1';

my @installed_kernels = split /\n/, qx/$list_command/;

# Should be fine until Linux 100.x
my $version_regex = qr/^linux.+(\d{1,2}\.\d{1,2}\.\d{1,2}-\d{1,3})/;

use Data::Dumper;
print Dumper \@installed_kernels;

my @victims;

foreach my $package (@installed_kernels) {
    push @victims, $package =~ /$version_regex/;
}

@victims = sort @victims;

# Spare the most recent two versions
print "Retaining the two most recent kernel versions:\n";
for (1..2) {
    print pop @victims, ' ';
}
print "\n";

print "Preparing to remove the following kernel versions:\n";
my @uninstall;
foreach my $victim (@victims) {
    print $victim, ' ';
    my $cmd = sprintf $victim_command, $victim;
    my @packages = split /\n/, qx/$cmd/;
    push @uninstall, @packages;
}
print "\n";

system "sudo aptitude purge @uninstall";

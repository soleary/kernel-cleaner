#!/usr/bin/perl

use warnings;
use strict;

my $list_command   = 'dpkg --get-selections | grep install | grep linux-image | cut -f1';
my $victim_command = 'dpkg --get-selections | grep install | grep linux | grep %s | cut -f1';

my @installed_kernels = split /\n/, qx/$list_command/;
my $version_regex = qr/^linux.+(\d+\.\d+\.\d+-\d+)/;

my @victims;
foreach my $package (@installed_kernels) {
    push @victims, $package =~ /$version_regex/;
}

@victims = sort @victims;

# Spare the two most recent kernel versions
print "Retaining the two most recent kernel versions:\n";
for (1..2) {
    print pop @victims, ' ';
}
print "\n";

my @uninstall;
foreach my $victim (@victims) {
    my $cmd = sprintf $victim_command, $victim;
    my @packages = split /\n/, qx/$cmd/;
    push @uninstall, @packages;
}

if (@uninstall) {
    print "Preparing to remove the following kernel versions:\n";
    print join ' ', @victims;
    print "\n";
    system "sudo aptitude purge @uninstall";
} else {
    print "No kernel packages to remove.\n";
}


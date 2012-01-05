#!/usr/bin/perl -w
use strict;
use diagnostics;
use Time::HiRes qw(usleep ualarm);
use Device::SerialPort;

fork && exit;

my $ircode;
# hardwired button
$ircode->{'1'} = 'builtin'; 
# Apple A1156 / http://lirc.sourceforge.net/remotes/apple/A1156 
# last byte must be stripped in code
$ircode->{'77E120'} = 'playpause';
$ircode->{'77E1D0'} = 'up';
$ircode->{'77E1B0'} = 'down';
$ircode->{'77E110'} = 'back';
$ircode->{'77E1E0'} = 'forward';
$ircode->{'77E140'} = 'menu';
# Martin's undocumented Sony MRC60
# match all bytes
$ircode->{'C1310EF'} = 'playpause';
$ircode->{'C1300FF'} = 'up';
$ircode->{'C13807F'} = 'down';
$ircode->{'C1320DF'} = 'back';
$ircode->{'C13A05F'} = 'forward';
$ircode->{'C1330CF'} = 'menu';
$ircode->{'C13906F'} = 'green';
$ircode->{'C13B04F'} = 'red';

$| = 1;
$0 = 'emergency_button_daemon';

my $device = shift @ARGV;
my @action = @ARGV;

my $port = Device::SerialPort->new($device);
die "can't open port: $!" unless $port;
$port->baudrate(57600);
$port->databits(8);
$port->parity("none");
$port->stopbits(1);
$port->write_settings();
sleep 1;
print "Start polling.\n";
my $available = 1;
$SIG{ALRM} = sub { $available = 1; };
while(1){
	$port->write("a");
	my $asked_at = time();
	my $received;
	while(1){
		if (time() - $asked_at > 2){
			die "Good grief! No serial comm! Arduino on fire?\n";
		}
		my $byte = $port->read(1);
		$received .= $byte;
		last if ($byte eq "\n");
	}
	# print $received;
	if ($received =~ /button=(.+) pressed=true/){
		if ($available){
			my $raw_button = $1;
			my $cooked_button = $raw_button;
			if ($raw_button =~ /^(77E1..)..$/){
				$cooked_button = $1;
			}
			my $action = 'unknown';
			if ($ircode->{$cooked_button}){
				$action = $ircode->{$cooked_button};
			}
			print "Detected buttonpress (raw) button=$raw_button, cooked=$cooked_button, action=$action\n";
			$ENV{'BUTTON_ACTION'} = $action;
			system(@ARGV);
			$available = 0;
			ualarm(500000);
		}else{
			print "Blocked buttonpress (event is blocked for 500ms).\n";
		}
	}
	usleep(200000);
}

__END__

Copyright (c) 2011, Martin Schmitt < mas at scsy dot de >

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

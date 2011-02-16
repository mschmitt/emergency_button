#!/usr/bin/perl -w
use strict;
use diagnostics;
use Time::HiRes qw(usleep ualarm);
use Device::SerialPort;

fork && exit;

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
	if ($received =~ /pressed=true/){
		if ($available){
			print "Detected buttonpress.\n";
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

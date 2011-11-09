#!/usr/bin/perl -w
use strict;
use diagnostics;
use HTML::LinkExtractor;
use LWP::Simple qw( get getstore );
use File::Copy;

# Retrieve a random MP3 file from a indexable web server directory
my $want_regex = qr/\.mp3$/i;

my $base = $ARGV[0];
my $html = get($base) or die "Specify proper URL leading to http directory";

my $LX = new HTML::LinkExtractor();
$LX->parse(\$html);

my @available;
foreach (@{$LX->links()}){
	next unless $_->{'href'};
	my $href = $_->{'href'};
	next unless ($href =~ $want_regex);
	push @available, $href;
}

exit unless @available;

my $random = $available[int rand scalar @available];
print "Chosen file: $random (copying to /tmp/random.mp3)\n";
my $foo = getstore("$base/$random", "/tmp/random-$$.mp3");
move ("/tmp/random-$$.mp3", "/tmp/random.mp3");

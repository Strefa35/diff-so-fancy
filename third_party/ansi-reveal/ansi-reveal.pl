#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;

my $raw = 0;
GetOptions(
	'raw' => \$raw,
);

if ($raw) {
	output_raw();
} else {
	output_human();
}

###############################################

sub output_human {
	my $reset = "\e[0m";

	while (my $l = <>) {
		$l =~ s/(\e\[.*?m)/dump_ansi($1)/eg;

		print $l;
	}
}

###############################################

sub output_raw {
	while (<>) {
		s/\e/\\e/g;
		print;
	}
}

sub dump_ansi {
	my $str   = shift();
	if ($str !~ /^\e/) {
		return "";
	}

	my $raw   = $str;
	my $human = $str =~ s/\e/ESC/rg;

	# Remove the ANSI control chars, we just want the payload
	$str =~ s/^\e\[//g;
	$str =~ s/m$//g;

	# Make the [HUMAN] text reset and white to make it easier to see
	my $ret  = "\e[0m";
	$ret    .= "\e[38;5;15m";

	my @parts = split(";",$str);

	#k(\@parts);

	my @basic_mapping = qw(BLACK RED GREEN YELLW BLUE MAGNT CYAN WHITE);

	if (!@parts) {
		$ret .= "[RESET]";
	}

	for (my $count = 0; $count < @parts; $count++) {
		my $p = $parts[$count];

		#print "[$count = '$p']\n";
		if ($p eq "1") {
			$ret .= "[BOLD]";
		} elsif ($p eq "0" || $p eq "") {
			$ret .= "[RESET]";
		} elsif ($p eq "7") {
			$ret .= "[REVERSE]";
		} elsif ($p eq "27") {
			$ret .= "[NOTREV]";
		} elsif ($p eq "38") {
			my $next  = $parts[$count + 1];
			my $color = $parts[$count + 2];

			$count += 2;

			$ret .= sprintf("[COLOR%03d]",$color);
		} elsif ($p eq "48") {
			my $next  = $parts[++$count];
			my $color = $parts[++$count];

			$count += 2;

			$ret .= sprintf("[BACKG%03d]",$color);
		} elsif ($p >= 30 and $p <= 37) {
			my $color = $p - 30;
			$color = $basic_mapping[$color];
			$ret .= "[$color]";
			#$ret .= sprintf("[BASIC%03d]",$color);
		} else {
			$ret .= "[UKN: $p]";
		}
	}

	# Append the ANSI color string to end of the human readable one
	$ret .= $raw;

	return $ret;
}

BEGIN {
	if (eval { require Data::Dump::Color }) {
		*k = sub { Data::Dump::Color::dd($_[0]) };
	} else {
		require Data::Dumper;
		*k = sub { print Data::Dumper::Dumper($_[0]) };
	}
}

# vim: tabstop=4 shiftwidth=4 autoindent softtabstop=4

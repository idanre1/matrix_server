#!/usr/bin/perl
my $filename = $ARGV[0];
my $from     = $ARGV[1];
my $to       = $ARGV[2];

# Read
my $txt;
open(my $fh, '<', $filename) or die "cannot open file $filename"; {
	local $/;
    $txt = <$fh>;
}
close($fh);

# Exe
$txt =~ s/$from.*?\n/${from} ${to}\n/g;

# WB
open(FH, '>', $filename) or die $!;
print FH $txt;
close(FH);

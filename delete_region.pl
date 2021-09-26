#!/usr/bin/perl
my $filename = $ARGV[0];
my $exp = $ARGV[1];

# Read
my $txt;
open(my $fh, '<', $filename) or die "cannot open file $filename"; {
	local $/;
    $txt = <$fh>;
}
close($fh);

# Exe
$txt =~ s/\n$exp.*?\n\n/\n\n\n/sg;

# WB
open(FH, '>', $filename) or die $!;
print FH $txt;
close(FH);

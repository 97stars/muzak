package Muzak::Convert;
use Exporter 'import';
@EXPORT_OK = qw(convert);

use IPC::Open2;

use strict;
use warnings;

sub convert {
    my ($infile, $outfile) = @_;
    $infile =~ /\.([^.]*$)/;
    my $inextension = $1;
    $outfile =~ /\.([^.]*$)/;
    my $outextension = $1;
    run(decode_flac($infile), encode_aac($outfile));
}

sub run {
    my ($cmd1, $cmd2) = @_;
    my ($decpid, $decin, $decout);
    my ($encpid, $encin, $encout);
    $decpid = open2($decout, $decin, @$cmd1);
    $encpid = open2($encout, $encin, @$cmd2);
    while (my $l = <$decout>) {
        print $encin $l;
    }
    waitpid($decpid, 0);
    waitpid($encpid, 0);
}

sub decode_flac {
    my ($file) = @_;
    return ["flac", "-f", "-d", $file, "-o", "-"];
}

sub encode_aac {
    my ($file) = @_;
    return ["neroAacEnc", "-q", "0.75", "-if", "-", "-of", $file];
}

1;

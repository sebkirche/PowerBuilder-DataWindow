
use strict;
use warnings;
use feature 'say';
use DataWindow;
use File::Slurp qw(slurp);
use Data::Dumper::GUI;


my $file = shift || die "usage : $0 <file.srd>";
die unless -f $file;

my $data = slurp($file);
my $dw = DataWindow->new();
$dw->parse($data);

say $dw->{select};
#Dumper($dw);
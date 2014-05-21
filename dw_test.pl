
use strict;
use warnings;
use feature 'say';
use DataWindow;
use File::Slurp qw(slurp);
#use Data::Dumper::GUI;
use Data::Dumper;


my $file = shift || die "usage : $0 <file.srd>";
die unless -f $file;

my $data = slurp($file);
my $dw = DataWindow->new();
$dw->parse($data);


say "Select from DB is: ". $dw->select;

#say Dumper(\$dw->select_columns);
say "SELECTed columns are:";
say "    " . $_ foreach (keys $dw->select_columns);

say "Columns definitions are:";
say "    " . $_ . "\t" . ${$dw->column_definitions}{$_}{type} foreach keys $dw->column_definitions;

say "Columns controls are:";
my @cols = keys $dw->control_columns; 
foreach (@cols){
	say "    " . $_ . "\tx=" . ${$dw->control_columns}{$_}{x};
}

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
my $selected = $dw->select_columns;
say "    " . $_ . " #" . $selected->{$_} foreach sort { $selected->{$a} <=> $selected->{$b} } keys $selected;

say "Columns definitions are:";
say "    " . $_->{name} . " type=" . $_->{type} . " #" . $_->{'#'} foreach sort { $a->{'#'} <=> $b->{'#'} } values $dw->column_definitions;

say "Columns controls are:";
say "    " . $_->{name} . " id=" . $_->{id} . " x=" . $_->{x} foreach sort { $a->{'id'} <=> $b->{'id'} } $dw->column_controls;

say "Texts controls are:";
say "    " . $_->{name} . " x=" . $_->{x} . " y=" . $_->{y} foreach sort { $a->{y} <=> $b->{y} || $a->{x} <=> $b->{x} } $dw->text_controls;

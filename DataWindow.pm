package DataWindow;

use strict;
use warnings;
use feature 'say';
use File::Slurp qw(read_file);
use MarpaX::Languages::PowerBuilder::SRD;
use Data::Dumper::GUI;

use constant DEBUG=> 0;

sub new {
	my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

$| = 1;

sub parse {
	my $self = shift;
    my $input = shift;
	
#    say "parsing $input" if DEBUG;
    
    #file or dw content ? if file, replace by content
    #do not use -f directly or it will show a warning when given the DW content : Unsuccessful stat on filename containing newline
    if ($input !~ /\n/ and -f $input) { $input = read_file($input); }
    
    my $parser = MarpaX::Languages::PowerBuilder::SRD::parse($input);
	if($parser->{error}){
    	die $parser->{error};
	}
    my $parsed = $parser->{recce}->value();
    my $retrieve = ${$parsed}->{table}->{retrieve};
	if($retrieve =~ /PBSELECT/){
    	use MarpaX::Languages::PowerBuilder::PBSelect;
        my $PBparser = MarpaX::Languages::PowerBuilder::PBSelect::parse($retrieve);
#		say $PBparser->{error} if $PBparser->{error};
        my $ast = $PBparser->{recce}->value;
#        Dumper(${$ast});
		$retrieve = MarpaX::Languages::PowerBuilder::PBSelect::to_sql(${$ast});
    }
#    say "select = $retrieve";
	$self->{select} = $retrieve;
	
}

1;

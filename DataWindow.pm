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
    Dumper(${$parsed}) if DEBUG;
    my $select = ${$parsed}->{table}->{retrieve};
	if($select =~ /PBSELECT/){
    	use MarpaX::Languages::PowerBuilder::PBSelect;
        my $PBparser = MarpaX::Languages::PowerBuilder::PBSelect::parse($select);
#		say $PBparser->{error} if $PBparser->{error};
        my $ast = $PBparser->{recce}->value;
#        Dumper(${$ast});
		$select = MarpaX::Languages::PowerBuilder::PBSelect::to_sql(${$ast});
    }
    say "select = $select" if DEBUG;
	$self->{select} = $select;
    $self->{sele} = ();
    
    #get the selected columns
#    my $j=1;
#    foreach ($select =~ /([\w_\d]+)\s*(?:,|FROM)/g){
#        $self->{sele}{lc $_} = $j;
##        s/t[^_]+_//g;
##        $self->{sele}{lc $_} = $j;
#        $j++;
#	}

	my $sel_cols;
	my @sel_lines = split(/\n/, $select);
    foreach (@sel_lines){
    	if (/^\s*SELECT/i .. /\s*FROM\s+/i){
            chomp;
            $sel_cols .= $_;
            #~ if(/^((?:\w|.|")+),$/){
                #~ $sele{$1} = $j;
                #~ $j++;
            #~ }
        }
    }
    $sel_cols =~ s/~"//g;					#clean escaped quotes
  	#get the selected columns
    my $j=1;
    foreach ($sel_cols =~ /([\w_\d]+)\s*(?:,|FROM)/g){
        $self->{sele}{lc $_} = $j;
#        s/t[^_]+_//g;
#        $sele{lc $_} = $j;
        $j++;
    }

#	Dumper(${$parsed}->{columns});
	$self->{controls} = ${$parsed}->{controls};
    
    $self->{datacolumns} = ${$parsed}->{table}{columns};
}

sub select {
	my $self = shift;
    return $self->{select};
}

sub select_columns {
	my $self = shift;
	return $self->{sele};
}

sub controls {
	my $self = shift;
    my $type = shift;
    return grep { $_->{type} =~ /$type/ } values $self->{controls};
}

sub column_controls {
	my $self = shift;
    return $self->controls("column");
}

sub text_controls {
	my $self = shift;
    return $self->controls("text");
}

sub column_definitions {
	my $self = shift;
    return $self->{datacolumns};
}

1;

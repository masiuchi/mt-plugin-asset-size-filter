package AssetSizeFilter::ListProps;
use strict;

use MT::FileMgr;

our $PLUGIN = MT->instance()->component( ( split /::/, __PACKAGE__ )[0] );
our $FMGR   = MT::FileMgr->new( 'Local' );

sub filter_tmpl {
    return <<'HTMLHEREDOC';
<mt:setvartemplate name="asset_size_filter">
<__trans phrase="[_1] [_2] [_3]"
         params="<mt:var name="label" escape="js">%%
                 <select class="<mt:var name="type">-type">
                   <option value="byte">Byte(s)</option>
                   <option value="kilo">KB</option>
                   <option value="mega">MB</option>
                   <option value="giga">GB</option>
                 </select>
                 <select class="<mt:var name="type">-option">
                   <option value="equal"><__trans phrase="__INTEGER_FILTER_EQUAL" escape="js"></option>
                   <option value="not_equal"><__trans phrase="__INTEGER_FILTER_NOT_EQUAL" escape="js"></option>
                   <option value="greater_than"><__trans phrase="is greater than" escape="js"></option>
                   <option value="greater_equal"><__trans phrase="is greater than or equal to" escape="js"></option>
                   <option value="less_than"><__trans phrase="is less than" escape="js"></option>
                   <option value="less_equal"><__trans phrase="is less than or equal to" escape="js"></option>
                 </select>%%
                 <input type="text" class="prop-integer <mt:var name="type">-value text num required digit" value="" />">
</mt:setvartemplate>
<mt:var name="asset_size_filter">
HTMLHEREDOC
}

#sub raw {
#    my ( $prop, $obj ) = @_;
#    return _get_file_size( $obj );
#}

sub html {
    my ( $prop, $obj, $app ) = @_;
    my $file_size = _get_file_size( $obj );
    $file_size    = _insert_comma( $file_size );
    my $out = qq{
        <div style="float: right;">$file_size</div>
    };
    return $out;
}

sub bulk_sort {
    my ( $prop, $objs ) = @_;
    return sort { _get_file_size( $a ) <=> _get_file_size( $b ) } @$objs;
}

sub terms {
    my $prop = shift;
    my ( $args, $db_terms, $db_args ) = @_;

    my %temp_args = %$db_args;
    $temp_args{limit}  = 50;
    $temp_args{offset} = 0;

    my $func = _get_func( $args );
    if ( !$func ) {
        die $PLUGIN->translate( 'error' );
    }

    my @ids;
    while ( my @objs = MT->model('asset')->load( $db_terms, \%temp_args ) ) {
        foreach my $obj ( @objs ) {
            my $file_size = _get_file_size( $obj );
            if ( $func->( $file_size ) ) {
                push @ids, $obj->id;
            }
        }
        $temp_args{offset} += 50;
    }

    if ( scalar @ids ) {
        return { id => \@ids };
    } else {
        return { id => \'is null' };
    }
}

sub _get_file_size {
    my ( $obj ) = @_;

    if ( my $file_path = $obj->file_path ) {
        if ( my $file_size = $FMGR->file_size( $file_path ) ) {
            return $file_size;
        }
    }

    return 0;
}

sub _get_func {
    my ( $args ) = @_;

    my $option = $args->{option};
    my $value  = $args->{value};
    my $type   = $args->{type};

    if ( $type eq 'kilo' ) {
        $value *= 1000;
    } elsif ( $type eq 'mega' ) {
        $value *= 1000000;
    } elsif ( $type eq 'giga' ) {
        $value *= 1000000000;
    }

    my $func;
    if ( 'equal' eq $option ) {
        $func = sub { return $_[0] == $value; };
    } elsif ( 'not_equal' eq $option ) {
        $func = sub { return $_[0] != $value; };
    } elsif ( 'greater_than' eq $option ) {
        $func = sub { return $_[0] > $value; };
    } elsif ( 'greater_equal' eq $option ) {
        $func = sub { return $_[0] >= $value; };
    } elsif ( 'less_than' eq $option ) {
        $func = sub { return $_[0] < $value; };
    } elsif ( 'less_equal' eq $option ) {
        $func = sub { return $_[0] <= $value; };
    }

    return $func;
}

sub _insert_comma {
    my ( $num ) = @_;

    my @split;
    while ( $num =~ /(\d\d\d)$/ ) {
        unshift @split, $1;
        $num =~ s/\d\d\d$//;
    }       
    if ( $num ne '' ) {
        unshift @split, $num;
    }   
    $num = join ',', @split;

    return $num;
}

1;
__END__

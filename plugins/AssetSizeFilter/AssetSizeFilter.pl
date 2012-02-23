package MT::Plugin::AssetSizeFilter;
use strict;
use base qw( MT::Plugin );

our $NAME = ( split /::/, __PACKAGE__ )[-1];

my $plugin = __PACKAGE__->new({
    name        => $NAME,
    id          => lc $NAME,
    key         => lc $NAME,
    l10n_class  => $NAME . '::L10N',
    version     => '0.01',
    author_name => 'masiuchi',
    author_link => 'https://github.com/masiuchi',
    plugin_link => 'https://github.com/masiuchi/mt-plugin-asset-size-filter',
    description => '<__trans phrase="Enable filtering by file size of asset.">',
});
MT->add_plugin( $plugin );

sub init_registry {
    my ( $p ) = @_;
    my $pkg = '$'.$NAME.'::'.$NAME.'::ListProps::';
    $p->registry( 'list_properties', 'asset', 'file_size', {
         base        => '__virtual.integer',
         label       => 'File Size',
         display     => 'default',
         filter_tmpl => $pkg . 'filter_tmpl',
         html        => $pkg . 'html',
#         raw         => $pkg . 'raw',
         bulk_sort   => $pkg . 'bulk_sort',
         terms       => $pkg . 'terms',
    } );
}

1;
__END__

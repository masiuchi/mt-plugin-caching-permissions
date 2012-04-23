package MT::Plugin::CachingPermissions;
use strict;
use warnings;
use base qw( MT::Plugin );

our $VERSION = '0.03';
our $NAME    = ( split /::/, __PACKAGE__ )[-1];

my $plugin = __PACKAGE__->new({
    name        => $NAME,
    id          => lc $NAME,
    key         => lc $NAME,
    l10n_class  => $NAME . '::L10N',
    version     => $VERSION,
    author_name => 'masiuchi',
    author_link => 'https://github.com/masiuchi/',
    plugin_link => 'https://github.com/masiuchi/mt-plugin-caching-permissions/',
    description => '<__trans phrase="Overwrite MT::Permission::perms_from_registry() for having cache when using MT 5.1 or later.">',
});
MT->add_plugin( $plugin );

if ( $MT::VERSION >= 5.1 ) {
    my $key = 'cachingpermssions:perms';
    my $overwritten;

    sub init_registry {
        my ( $p ) = @_;
        $p->registry({
            init_app => \&_init_app,
        });
    }

    sub _init_app {
        unless ( $overwritten ) {
            require MT::Permission;
            my $org = \&MT::Permission::perms_from_registry;

            require MT::Request;
            no warnings 'redefine';
            *MT::Permission::perms_from_registry = sub {
                my $req   = MT::Request->instance();
                my $cache = $req->cache( $key );
                unless ( $cache && %$cache ) {
                    my %perms = %{ $org->() };
                    $req->cache( $key, \%perms );
                }
                return $req->cache( $key );
            };

            $overwritten = 1;
        }
    }
}

1;
__END__

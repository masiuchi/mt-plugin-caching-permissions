package MT::Plugin::CachingPermissions;
use strict;
use warnings;
use base qw( MT::Plugin );

use MT::Permission;
use MT::Request;

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
    description => '<__trans phrase="Accelerate Movable Type interface for caching permmision registry.">',
});
MT->add_plugin( $plugin );

my $key = 'cachingpermissions:perms';
my $overwritten;

sub init_registry {
    my ( $p ) = @_;
    $p->registry({
        init_app => \&_init_app,
    });
}

sub _init_app {
    unless ( $overwritten ) {
        if ( $MT::VERSION >= 5.1 ) {
            my $org = \&MT::Permission::perms_from_registry;

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
        } else {
            my $org = \&MT::Permission::_confirm_action;

            no warnings 'redefine';
            *MT::Permission::_confirm_action = sub {
                my ( $pkg, $perm_name, $action, $permissions ) = @_;

                if ( !$permissions ) {
                    my $req = MT::Request->instance();
                    my $cache = $req->cache( $key );
                    unless ( $cache && %$cache ) {
                        my %perms = %{ MT->registry( 'permissions' ) };
                        $req->cache( $key, \%perms );
                    }
                    $permissions = $req->cache( $key );
                }

                return $org->( $pkg, $perm_name, $action, $permissions );
            };
        }

        $overwritten = 1;
    }
}

1;
__END__

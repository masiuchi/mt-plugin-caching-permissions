package MT::Plugin::CachingPermissions;
use strict;
use warnings;
use base qw( MT::Plugin );

return 1 if $MT::VERSION < 5.1;

our $VERSION = '0.02';
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
    registry    => {
        callbacks => {
            init_request => &_init_request,
        },
    },
});
MT->add_plugin( $plugin );

{
    my %Cache;
    sub _init_request { %Cache = () }

    require MT::Component;
    require MT::Permission;
    no warnings 'redefine';
    *MT::Permission::perms_from_registry = sub {
        return \%Cache if %Cache;
        my $regs  = MT::Component->registry('permissions');
        my %keys  = map { $_ => 1 } map { keys %$_ } @$regs;
        my %perms = map { $_ => MT->registry( 'permissions' => $_ ) } keys %keys;
        %Cache    = %perms;
        \%perms;
    };
}

1;
__END__

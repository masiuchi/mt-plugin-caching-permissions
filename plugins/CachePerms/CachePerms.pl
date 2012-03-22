package MT::Plugin::CachePerms;
use strict;
use warnings;
use base qw( MT::Plugin );

our $VERSION = '0.01';
our $NAME    = ( split /::/, __PACKAGE__ )[-1];

my $plugin = __PACKAGE__->new({
    name        => $NAME,
    id          => lc $NAME,
    key         => lc $NAME,
    l10n_class  => $NAME . '::L10N',
    version     => $VERSION,
    author_name => 'masiuchi',
    author_link => 'https://github.com/masiuchi/',
    plugin_link => 'https://github.com/masiuchi/mt-plugin-cache-perms/',
    description => '<__trans phrase="Overwrite MT::Permission::perms_from_registry() for having cache when using MT 5.1 or later.">',
});
MT->add_plugin( $plugin );

if ( $MT::VERSION >= 5.1 ) {
    require MT::Component;
    require MT::Permission;
    no warnings 'redefine';
    my %cached_perms;
    *MT::Permission::perms_from_registry = sub {
        if ( defined %cached_perms ) {
            return \%cached_perms;
        }
        my $regs  = MT::Component->registry('permissions');
        my %keys  = map { $_ => 1 } map { keys %$_ } @$regs;
        my %perms = map { $_ => MT->registry( 'permissions' => $_ ) } keys %keys;
        %cached_perms = %perms;
        \%perms;
    };
}

1;
__END__

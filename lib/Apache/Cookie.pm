# Tue Apr  6 19:28:55 IDT 1999
package Apache::Cookie;

use Apache ();
use CGI::Cookie ();
use vars qw($VERSION);

$VERSION = '0.1';

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $r = shift || Apache->request;
    
    my $self = { 'r' => $r };
    bless $self, $class;
}

sub set {
    my $self = shift;
    my $r = ref($self) ? $self->{'r'} : Apache->request;
    my $cookie = CGI::Cookie->new(@_);
    $r->cgi_header_out('Set-Cookie' => "$cookie") if "$cookie";
}

sub get {
    my $self = shift;
    my $r = ref($self) ? $self->{'r'} : Apache->request;
    my $cookie_name = shift;

    my %cookies = ref($self) ? %{$self->{'.cookies'}} : ();
    unless(%cookies) {
        my %cookiejar = CGI::Cookie->parse($r->header_in('Cookie'));
        %cookies = map { $_->{'name'} => $_->{'value'} } values %cookiejar;
        $self->{'.cookies'} = \%cookies if ref($self);
    }

    return %cookies unless $cookie_name;
    return () unless %cookies and $cookies{$cookie_name};
    return @{$cookies{$cookie_name}} if wantarray;
    return $cookies{$cookie_name}->[0];
}

1;
__END__
    

=head1 NAME

The Apache::Cookie module - An OO interface to cookies based on
CGI::Cookie, for use in mod_perl Apache modules.

=head1 SYNOPSIS

 use Apache::Cookie;

 $r = Apache->request;

 # Object oriented
 $cookie = Apache::Cookie->new($r);

 $cookie->set(-name => 'cookie', -value => 'monster');
 $value = $cookie->get('cookie');

 # Package oriented
 Apache::Cookie->set(-name => 'cookie', -value => 'monster');
 Apache::Cookie->get('cookie');

=head1 DESCRIPTION

Grinding my teeth, browsing over Apache::AuthCookie I figure
there has to be a nice worry-free way of using cookies within
apache modules. There wasn't. So I decided to sit down and figure
it out. Apache::Cookie is the result.

=head1 CONSTRUCTOR

=over 4

=item Apache::Cookie->new([ $r ])

Construct a new Apache::Cookie object. You don't really have to,
but if your zealous $r is an Apache request object. If your just
looking to manipulate cookies in this request the Package oriented
model will do you just fine.

=item set( %OPTIONS )

Set a cookie on the client. We take your options and grind them
through a CGI::Cookie constructor, stringify the cookie and send
it over to our client's cookie jar (by Set-Cookie header).

Say...

         Apache::Cookie->set(-name => 'foo',
                             -value   =>  'bar',
                             -expires =>  '+3M',
                             -domain  =>  '.capricorn.com',
                             -path    =>  '/cgi-bin/database'
                             -secure  =>  1
                             );

For further info, take a look at the CGI::Cookie documentation.

BTW, the undocumented Apache $r->cgi_header_out is used to set headers,
very useful, but might be deprecated in the future.

=item get( [$COOKIE_NAME] )

Dip into the client's transmitted cookie jar.
What you get depends on what you call this method with.

Apache::Cookie->get()

Poof! you just won a hash of cookies, with array reference
values. You always get back array references, this is uncomfortable
but at least consistent with what CGI::Cookie->parse returns.

Apache::Cookie->get($COOKIE_NAME)

 If $COOKIE_NAME was set by the client, you get back the value.
 If your expecting a scalar, your going to get one.
 If your expecting an array, likewise.

Expect an array when the Cookie value is a scalar and you'll get
a single item array.

Expect a scalar when the Cookie value is an array and you'll get
the first array value.

=head1 SEE ALSO

L<CGI::Cookie>, L<CGI>
    

=head1 AUTHOR

 Liraz Siri <liraz_siri@usa.net>, Ariel, Israel.
 Copyrights 1999 (c) All rights reserved.

=back
    
=cut

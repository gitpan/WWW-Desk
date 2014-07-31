package WWW::Desk::Auth::oAuth;

use 5.006;
use strict;
use warnings;

use Moose;
use Net::OAuth::Simple;
use Mojo::URL;

=head1 NAME

WWW::Desk::Auth::oAuth - Desk.com oAuth Authentication

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 ATTRIBUTES

=head2 api_key

REQUIRED - desk.com api key

=cut

has 'api_key' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

=head2 secret_key

REQUIRED - desk.com api secret key

=cut

has 'secret_key' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

=head2 desk_url

REQUIRED - your desk url

=cut

has 'desk_url' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

=head2 callback_url

REQUIRED - desk.com oauth callback url

=cut

has 'callback_url' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

=head2 auth_client

Net::OAuth::Simple OAuth protocol object wrapper

=cut

has 'auth_client' => (
    is         => 'ro',
    isa        => 'Net::OAuth::Simple',
    lazy_build => 1
);

sub _build_auth_client {
    my ($self) = @_;
    return Net::OAuth::Simple->new(
        tokens => {
            consumer_key    => $self->api_key,
            consumer_secret => $self->secret_key,
        },
        protocol_version => '1.0a',
        urls             => {
            authorization_url => $self->_prepare_url('/oauth/authorize'),
            request_token_url => $self->_prepare_url('/oauth/request_token'),
            access_token_url  => $self->_prepare_url('/oauth/access_token')
        }
    );
}

sub _prepare_url {
    my ( $self, $path ) = @_;
    return Mojo::URL->new( $self->desk_url )->path($path)->to_abs();
}

=head1 SYNOPSIS

    use WWW::Desk::Auth::oAuth;

    my $auth = WWW::Desk::Auth::oAuth->new(
        'api_key'      => 'api key',
        'secret_key'   => 'secret key',
        'desk_url'     => 'https://my.desk.com',
        'callback_url' => 'https://myapp.com/callback'
    );

    if ( $auth->is_authorize ){
        // make restricted content request
    }
    else {
        print "Please visit this url to authorize ". $auth->authorization_url;
    }


=head1 SUBROUTINES/METHODS

=head2 is_authorized

Whether the client has the necessary credentials to be authorized. Authorization url can be used to get the authentication 

=cut

sub is_authorized {
    my ($self) = @_;
    return $self->auth_client->authorized;
}

=head2 authorization_url

Authorization url the user needs to visit to authorize 

=cut

sub authorization_url {
    my ($self) = @_;
    return $self->auth_client->get_authorization_url(
        callback => $self->callback_url )->as_string;
}

=head2 request_token

Returns the current request token. 

=cut

sub request_token {
    my ($self) = @_;
    return $self->auth_client->request_token;
}

=head2 request_token_secret

Returns the current request token secret. 

=cut

sub request_token_secret {
    my ($self) = @_;
    return $self->auth_client->request_token_secret;
}

=head1 AUTHOR

binary.com, C<< <rakesh at binary.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-desk at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Desk>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Desk


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Desk>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Desk>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Desk>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Desk/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 binary.com.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

no Moose;
__PACKAGE__->meta->make_immutable();

1;    # End of WWW::Desk::Auth::oAuth

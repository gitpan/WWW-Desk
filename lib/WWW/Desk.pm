package WWW::Desk;

use 5.006;
use strict;
use warnings FATAL => 'all';

use Moose;
use Carp;
use WWW::Desk::Browser;

=head1 NAME

WWW::Desk - Desk.com perl API

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

WWW::Desk will allow you make all API calls using HTTP or oAuth authentication

    use WWW::Desk;
    use WWW::Desk::Auth::HTTP;

    my $auth = WWW::Desk::Auth::HTTP->new(
        'username' => 'desk username',
        'password' => 'desk password'
    );
    my $desk = WWW::Desk->new(
        'desk_url'       => 'https://your.desk.com/',
        'authentication' => $auth,
    );
    my $response = $desk->call('/cases','GET', {'locale' => 'en_US'} );

=cut

=head1 METHOD

    sub call {
        my ( $self, $url_fragment, $http_method, $params ) = @_;
        ...
    }

    Call method accepts
        $url_fragment - API fragment url
        $http_method  - HTTP method, Only supported GET, POST, PATCH, DELETE
        $params       - Additional Parameters which you want to send as query parameters


=head1 ATTRIBUTES

=head2 desk_url

REQUIRED - your desk url

=cut

has 'desk_url' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has 'browser_client' => (
    is         => 'ro',
    isa        => 'WWW::Desk::Browser',
    lazy_build => 1,
);

sub _build_browser_client {
    my ($self) = @_;
    return WWW::Desk::Browser->new( base_url => $self->desk_url );
}

=head2 authentication

REQUIRED - WWW::Desk::Auth::HTTP or WWW::Desk::Auth::oAuth object

=cut

has 'authentication' => (
    is       => 'ro',
    isa      => 'Object',
    required => 1
);

=head1 SUBROUTINES/METHODS

=head2 call

call method will allow you to make API calls.
url fragment, http method are required to make call

you can also pass params next to http method to add additional paramerters to the url

=cut

sub call {
    my ( $self, $url_fragment, $http_method, $params ) = @_;

    if ( not defined $params ) {
        $params = { 't' => time() };
    }

    return $self->_prepare_response( "400",
        "Argument must be supplied as HASH" )
      unless ref $params eq 'HASH';

    return $self->_prepare_response( "400",
        "Invalid HTTP method. Only supported GET, POST, PATCH, DELETE" )
      unless $http_method =~ /^GET$|^POST$|^PATCH$|^DELETE$/i;

    $http_method = lc $http_method;
    my $browser_client = $self->browser_client;
    my $request_url    = $browser_client->prepare_url($url_fragment);

    my $response;

    my $authentication = $self->authentication;
    if ( ref($authentication) eq 'WWW::Desk::Auth::HTTP' ) {

        my $json_params =
          $params ? $browser_client->js_encode($params) : $params;
        my $http_headers = $self->authentication->login_headers->to_hash();
        $response =
          $browser_client->browser->$http_method(
            $request_url => $http_headers => $json_params );
    }
    elsif ( ref($authentication) eq 'WWW::Desk::Auth::oAuth' ) {
        $response =
          $authentication->auth_client->view_restricted_resource( $request_url,
            $http_method, $params );
    }
    else {
        return $self->_prepare_response( "501",
            "Authentication Not Implemented" );
    }
    my $error = $response->error;
    return $self->_prepare_response( $error->{'code'} || 408,
        $error->{'message'} )
      if $error;

    return $self->_prepare_response( $error->{'code'} || 200,
        $error->{'message'}, $response->res->body );
}

sub _prepare_response {
    my ( $self, $code, $msg, $data ) = @_;
    $data = $self->browser_client->json->decode($data) if $data;
    return {
        'code'    => $code,
        'message' => $msg,
        'data'    => $data
    };
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

1;    # End of WWW::Desk

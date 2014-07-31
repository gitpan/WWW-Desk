#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';

use WWW::Desk;
use WWW::Desk::Auth::HTTP;

use Test::More;
use Test::FailWarnings;
use Test::Exception;
use Data::Dumper;

plan tests => 4;

subtest "WWW::Desk object attribute require test" => sub {
    plan tests => 4;
    throws_ok { WWW::Desk->new() } qr/Attribute \(authentication\) is required/,
      "missing authentication argument";

    throws_ok {
        WWW::Desk->new( authentication => 'Authentication' );
    }
    qr/Attribute \(authentication\) does not pass the type constraint/,
      "authentication type failed";

    my $auth = WWW::Desk::Auth::HTTP->new(
        'username' => 'username',
        'password' => 'password'
    );
    throws_ok {
        WWW::Desk->new( authentication => $auth );
    }
    qr/Attribute \(desk_url\) is required/, "missing desk_url argument";

    lives_ok {
        WWW::Desk->new(
            authentication => $auth,
            desk_url       => 'https://test.desk.com'
        );
    }
    "object constructed";
};

subtest "WWW::Desk validate authentication module" => sub {
    plan tests => 2;

    my $auth = Data::Dumper->new( [ 'test', 'test2' ] );
    my $desk = WWW::Desk->new(
        authentication => $auth,
        desk_url       => 'https://test.desk.com'
    );
    lives_ok { $desk } "object constructed with invalid authentication";

    is(
        $desk->call( '/hello', 'GET' )->{'message'},
        'Authentication Not Implemented',
        "Authentication Not Implemented exception"
    );
};

subtest "WWW::Desk validate http method" => sub {
    plan tests => 1;

    my $auth = WWW::Desk::Auth::HTTP->new(
        'username' => 'username',
        'password' => 'password'
    );
    my $desk = WWW::Desk->new(
        authentication => $auth,
        desk_url       => 'https://test.desk.com'
    );
    is(
        $desk->call( '/hello', 'GETE' )->{'message'},
        'Invalid HTTP method. Only supported GET, POST, PATCH, DELETE',
        "Invalid HTTP method exception"
    );
};

subtest "WWW::Desk validate call method" => sub {
    plan tests => 2;

    my $auth = WWW::Desk::Auth::HTTP->new(
        'username' => 'username',
        'password' => 'password'
    );
    my $desk = WWW::Desk->new(
        authentication => $auth,
        desk_url       => 'https://test.desk.com'
    );
    is( $desk->call( '/hello', 'GET' )->{'message'},
        'Not Found', "URL exception message" );
    is( $desk->call( '/hello', 'GET' )->{'code'}, '404', "URL exception code" );
};

done_testing();


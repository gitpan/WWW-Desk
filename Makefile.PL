use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'WWW::Desk',
    AUTHOR             => q{binary.com <rakesh@binary.com>},
    VERSION_FROM       => 'lib/WWW/Desk.pm',
    ABSTRACT_FROM      => 'lib/WWW/Desk.pm',
    LICENSE            => 'Artistic_2_0',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => 0, },
    BUILD_REQUIRES     => {
        'Test::More'      => 0,
        'Test::Exception' => 0,
    },
    PREREQ_PM => {
        'Moose'              => 0,
        'Mojo::UserAgent'    => 0,
        'Mojo::Headers'      => 0,
        'Mojo::Path'         => 0,
        'Mojo::URL'          => 0,
        'Net::OAuth::Simple' => 0,
        'MIME::Base64'       => 0,
        'Mojo::JSON'         => 0,
        'Carp'               => 0,
    },
    (
        !eval { ExtUtils::MakeMaker->VERSION(6.46) }
        ? ()
        : (
            META_ADD => {
                resources => {
                    homepage   => 'https://github.com/binary-com/perl-WWW-Desk',
                    repository => 'git@github.com:binary-com/perl-WWW-Desk.git',
                    bugtracker =>
                      'http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Desk',
                },
            }
        )
    ),
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'WWW-Desk-*' },
);

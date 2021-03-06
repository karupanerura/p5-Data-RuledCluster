#!perl
use strict;
use warnings;
BEGIN {
    unshift @INC, 'inc';

    # author requires, or bundled modules
    my @devmods = qw(
        inc::Module::Install             1.00
        Module::Install::AuthorTests     0.002
        Module::Install::Repository      0.06
        Test::Requires                   0.06
    );
    my @not_available;
    while(my($mod, $ver) = splice @devmods, 0, 2) {
        eval qq{use $mod $ver (); 1} or push @not_available, $mod;
    }
    if(@not_available) {
        print qq{# The following modules are not available.\n};
        print qq{# `perl $0 | cpanm` will install them:\n};
        print $_, "\n" for @not_available;
        exit 1;
     }
}
use inc::Module::Install;

all_from 'lib/Data/RuledCluster.pm';


test_requires 'Test::More'     => '0.88';
test_requires 'Test::Requires' => '0.06';
test_requires 'DBI'            => '0';
test_requires 'DBD::SQLite'    => '0';

requires 'Class::Load' => '0';
requires 'Data::Util'  => '0';

auto_set_repository;

tests_recursive;
author_tests 'xt';


clean_files qw(
    Data-RuledCluster-*
    *.stackdump
    cover_db *.gcov *.gcda *.gcno
    nytprof
    *.out
);

WriteAll(check_nmake => 0);

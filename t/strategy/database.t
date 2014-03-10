use strict;
use warnings;
use Test::More;
use Data::RuledCluster;
use DBI;
use File::Temp qw(tempdir);

my $tempdir  = tempdir CLEANUP => 1;
my $dr = Data::RuledCluster->new(
    config   => undef,
    callback => undef,
);

subtest 'Database Strategy' => sub {
    my $config = +{
        clusters => +{
            CLUSTER => +{
                strategy => 'Database',
                sql      => 'SELECT node FROM node_info WHERE user_id = ?',
            },
        },
        node => +{
            MASTER     => ["dbi:SQLite:dbname=$tempdir/master", '', ''],
            CLUSTER001 => ['dbi:mysql:slave001', '', '',],
            CLUSTER002 => ['dbi:mysql:slave002', '', '',],
        },
    };
    $dr->config($config);
    my $node  = $dr->resolve('MASTER');
    my $dbh   = DBI->connect(@{$node->{node_info}});

    {
        $dbh->do(<< 'SQL');
CREATE TABLE node_info (
    user_id int(10) NOT NULL,
    node    varchar(32) NOT NULL
);
SQL
        my $stmt = 'INSERT INTO node_info(user_id, node) VALUES(?, ?)';
        $dbh->do($stmt, undef, (101, 'CLUSTER001'));
        $dbh->do($stmt, undef, (102, 'CLUSTER002'));
        $dbh->do($stmt, undef, (103, 'CLUSTER002'));
    }

    is_deeply $dr->resolve('CLUSTER', 101, { dbh => $dbh }), {
        node      => 'CLUSTER001',
        node_info => ['dbi:mysql:slave001', '', ''],
    };
    is_deeply $dr->resolve('CLUSTER', 102, { dbh => $dbh }), {
        node      => 'CLUSTER002',
        node_info => ['dbi:mysql:slave002', '', ''],
    };
    is_deeply $dr->resolve('CLUSTER', 103, { dbh => $dbh }), {
        node      => 'CLUSTER002',
        node_info => ['dbi:mysql:slave002', '', ''],
    };

    my $resolve_node_keys = $dr->resolve_node_keys('CLUSTER', [qw/101 102 103/], undef, { dbh => $dbh });
    note explain $resolve_node_keys;
    is_deeply $resolve_node_keys, {
        CLUSTER001 => [qw/101/],
        CLUSTER002 => [qw/102 103/],
    }
};

done_testing;

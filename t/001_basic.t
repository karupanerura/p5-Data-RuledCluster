use strict;
use warnings;
use Test::More;
use Data::RuledCluster;

my $dr = Data::RuledCluster->new(
    config   => undef,
    callback => undef,
);

subtest 'basic method' => sub {
    my $config = +{
        clusters => +{
            USER_W => [qw/USER001_W USER002_W/],
            USER_R => [qw/USER001_R USER002_R/],
        },
        node => +{
            USER001_W => ['dbi:mysql:user001', 'root', '',],
            USER002_W => ['dbi:mysql:user002', 'root', '',],
            USER001_R => ['dbi:mysql:user001', 'root', '',],
            USER002_R => ['dbi:mysql:user002', 'root', '',],
        },
    };
    $dr->config($config);

    ok $dr->is_cluster('USER_W');
    ok $dr->is_cluster('USER_R');
    ok $dr->is_node('USER001_W');
    ok $dr->is_node('USER002_W');
    ok $dr->is_node('USER001_R');
    ok $dr->is_node('USER002_R');

    my $nodes;
    $nodes = $dr->clusters('USER_W');
    note explain $nodes;
    is_deeply $nodes, [qw/USER001_W USER002_W/];

    $nodes = $dr->clusters('USER_R');
    note explain $nodes;
    is_deeply $nodes, [qw/USER001_R USER002_R/];
};

done_testing;
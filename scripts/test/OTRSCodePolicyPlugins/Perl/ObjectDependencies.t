# --
# OTRSCodePolicyPlugins/Perl/ObjectDependencies.t - code policy self tests
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
use strict;
use warnings;
## nofilter(TidyAll::Plugin::OTRS::Common::CustomizationMarkers);

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'ObjectDependencies, no OM used.',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, default dependencies used',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
$Kernel::OM->Get('Kernel::System::Encode');
EOF
        Exception => 0,
    },
    {
        Name => 'ObjectDependencies, default dependencies used with invalid short form in Get()',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
our @ObjectDependencies = ('EncodeObject');
$Kernel::OM->Get('EncodeObject');
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, undeclared dependency used',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, dependency declared',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, dependency declared, valid short form',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
for my $Needed (qw(TicketObject)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, undeclared dependency in loop',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
for my $Needed (qw(TicketObject)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, undeclared dependency used with ObjectHash',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
$Kernel::OM->ObjectHash(
    Objects => [
        'TicketObject',
        'CustomObject',
    ],
);
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, declared dependency used with ObjectHash and Get',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Encode',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Time',
    'Kernel::System::Ticket',
    qw(Kernel::System::CustomObject Kernel::System::Custom2Object),
    'Kernel::System::Custom3Object',
);
$Kernel::OM->ObjectHash(
    Objects => [
        qw(TicketObject Kernel::System::CustomObject),
        'Kernel::System::Custom2Object',
    ],
);
$Kernel::OM->Get('Kernel::System::Custom3Object');
$Kernel::OM->Get('Kernel::System::Main');
EOF
        Exception => 0,
    },
    {
        Name => 'ObjectDependencies, undeclared default dependency used with ObjectHash and Get',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
our @ObjectDependencies = (
    'Kernel::System::Ticket',
    qw(Kernel::System::CustomObject Kernel::System::Custom2Object),
    'Kernel::System::Custom3Object',
);
$Kernel::OM->ObjectHash(
    Objects => [
        qw(TicketObject Kernel::System::CustomObject),
        'Kernel::System::Custom2Object',
    ],
);
$Kernel::OM->Get('Kernel::System::Custom3Object');
$Kernel::OM->Get('Kernel::System::Main');
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, Get called in for loop',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
for my $Needed (qw(Kernel::System::CustomObject)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, complex code, undeclared dependency',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
$Self->{ConfigObject} = $Kernel::OM->Get('Kernel::System::Config');
$Kernel::OM->ObjectParamAdd(
    LogObject => {
        LogPrefix => $Self->{ConfigObject}->Get('CGILogPrefix'),
    },
    ParamObject => {
        WebRequest => $Param{WebRequest} || 0,
    },
);

for my $Object (
    qw( LogObject EncodeObject SessionObject MainObject TimeObject ParamObject UserObject GroupObject )
    )
{
    $Self->{$Object} = $Kernel::OM->Get($Object);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, complex code, undeclared dependency',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Encode',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Time',
    'Kernel::System::User',
    'Kernel::System::Group',
    'Kernel::System::AuthSession',
    'Kernel::System::Web::Request',
);

$Self->{ConfigObject} = $Kernel::OM->Get('Kernel::Config');
$Kernel::OM->ObjectParamAdd(
    LogObject => {
        LogPrefix => $Self->{ConfigObject}->Get('CGILogPrefix'),
    },
    ParamObject => {
        WebRequest => $Param{WebRequest} || 0,
    },
);

for my $Object (
    qw( LogObject EncodeObject SessionObject MainObject TimeObject ParamObject UserObject GroupObject )
    )
{
    $Self->{$Object} = $Kernel::OM->Get($Object);
}
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, object manager disabled',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '3.4',
        Source    => <<'EOF',
our $ObjectManagerDisabled = 1;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::PodChecker;
use strict;
use warnings;

use Capture::Tiny qw(capture_merged);
use Pod::Checker;

use base 'Code::TidyAll::Plugin';
use base 'TidyAll::Plugin::OTRS::Base';

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    return if $Self->IsPluginDisabled( Filename => $File );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my $Checker = new Pod::Checker();

    # Force stringification of $File as it is a Path::Tiny object in Code::TidyAll 0.50+.
    my $Output = capture_merged { $Checker->parse_from_file( "$File", \*STDERR ) };

    # Only die if Output is filled with errors. Otherwise it could be
    #   that there just was no POD in the file.
    if ( $Checker->num_errors() && $Output ) {
        die __PACKAGE__ . "\n$Output";
    }
}

1;

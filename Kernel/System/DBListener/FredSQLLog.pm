# --
# Kernel/System/DBListener/FredSQLLog.pm
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: FredSQLLog.pm,v 1.3 2012-06-30 08:38:20 ub Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::DBListener::FredSQLLog;

use Kernel::System::Fred::SQLLog;

use Time::HiRes qw(gettimeofday tv_interval);

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.3 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Object (qw(ConfigObject LogObject)) {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    $Self->{SQLLogObject} = Kernel::System::Fred::SQLLog->new(%Param);

    $Self->{Active} = $Self->{ConfigObject}->Get('Fred::Module')->{SQLLog}->{Active};

    return $Self;
}

sub PrePrepare {
    my ( $Self, %Param ) = @_;

    return if ( !$Self->{Active} );

    $Self->{PrepareStart} = [gettimeofday];
}

sub PostPrepare {
    my ( $Self, %Param ) = @_;

    return if ( !$Self->{Active} );

    my $DiffTime = tv_interval( $Self->{PrepareStart} );

    my @StackTrace;

    COUNT:
    for ( my $Count = 1; $Count < 30; $Count++ ) {
        my ( $Package1, $Filename1, $Line1, $Subroutine1 ) = caller($Count);
        last COUNT if !$Line1;
        my ( $Package2, $Filename2, $Line2, $Subroutine2 ) = caller( 1 + $Count );
        $Subroutine2 ||= $0;    # if there is no caller module use the file name
        $Subroutine2 =~ s/Kernel::System/K::S/;
        $Subroutine2 =~ s/Kernel::Modules/K::M/;
        $Subroutine2 =~ s/Kernel::Output/K::O/;
        push @StackTrace, "$Subroutine2:$Line1";
    }

    my @Array = map { defined $_ ? $_ : 'undef' } @{ $Param{Bind} || [] };
    my $BindString = @Array ? join ', ', @Array : '';
    $Self->{SQLLogObject}->InsertWord(
        What => "SQL-SELECT##!##$Param{SQL}##!##$BindString##!##"
            . join( ';', @StackTrace )
            . "##!##$DiffTime",
    );
}

sub PreDo {
    my ( $Self, %Param ) = @_;

    return if ( !$Self->{Active} );

    $Self->{DoStart} = [gettimeofday];
}

sub PostDo {
    my ( $Self, %Param ) = @_;

    return if ( !$Self->{Active} );

    my $DiffTime = tv_interval( $Self->{DoStart} );

    my @StackTrace;

    COUNT:
    for ( my $Count = 1; $Count < 30; $Count++ ) {
        my ( $Package1, $Filename1, $Line1, $Subroutine1 ) = caller($Count);
        last COUNT if !$Line1;
        my ( $Package2, $Filename2, $Line2, $Subroutine2 ) = caller( 1 + $Count );
        $Subroutine2 ||= $0;    # if there is no caller module use the file name
        $Subroutine2 =~ s/Kernel::System/K::S/;
        $Subroutine2 =~ s/Kernel::Modules/K::M/;
        push @StackTrace, "$Subroutine2:$Line1";
    }

    my @Array = map { defined $_ ? $_ : 'undef' } @{ $Param{Bind} || [] };
    my $BindString = @Array ? join ', ', @Array : '';
    $Self->{SQLLogObject}->InsertWord(
        What => "SQL-DO##!##$Param{SQL}##!##$BindString##!##"
            . join( ';', @StackTrace )
            . "##!##$DiffTime",
    );
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

=head1 VERSION

$Revision: 1.3 $ $Date: 2012-06-30 08:38:20 $

=cut

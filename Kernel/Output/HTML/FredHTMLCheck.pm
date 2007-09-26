# --
# Kernel/Output/HTML/FredHTMLCheck.pm - layout backend module
# Copyright (C) 2001-2007 OTRS GmbH, http://otrs.org/
# --
# $Id: FredHTMLCheck.pm,v 1.2 2007-09-26 10:02:58 mh Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::Output::HTML::FredHTMLCheck;

use strict;
use warnings;

use vars qw(@ISA $VERSION);
$VERSION = '$Revision: 1.2 $';
$VERSION =~ s/^\$.*:\W(.*)\W.+?$/$1/;

=head1 NAME

Kernel::Output::HTML::FredHTMLCheck - layout backend module

=head1 SYNOPSIS

All layout functions of HTML check object

=over 4

=cut

=item new()

create a object

    $BackendObject = Kernel::Output::HTML::FredSTDERRLog->new(
        %Param,
    );

=cut

sub new {
    my $Type  = shift;
    my %Param = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (qw(ConfigObject LogObject LayoutObject)) {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    return $Self;
}

=item CreateFredOutput()

create the output of the STDERR log

    $LayoutObject->CreateFredOutput(
        ModulesRef => $ModulesRef,
    );

=cut

sub CreateFredOutput {
    my $Self      = shift;
    my %Param     = @_;
    my $HTMLLines = '';

    # check needed stuff
    if ( !$Param{ModuleRef} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need ModuleRef!',
        );
        return;
    }

    if ($Param{ModuleRef}->{Data}) {
        for my $Line ( reverse @{ $Param{ModuleRef}->{Data} } ) {
            $Line = $Self->{LayoutObject}->Ascii2Html(Text => $Line);
            $HTMLLines .= "        <tr><td>$Line</td></tr>\n";
        }

        if ($HTMLLines) {
            $Param{ModuleRef}->{Output} = $Self->{LayoutObject}->Output(
                TemplateFile => 'DevelFredHTMLCheck',
                Data         => {
                    HTMLLines => $HTMLLines,
                },
            );
        }
    }
    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see http://www.gnu.org/licenses/gpl.txt.

=cut

=head1 VERSION

$Revision: 1.2 $ $Date: 2007-09-26 10:02:58 $

=cut
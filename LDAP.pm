# -*- mode: perl -*-
#
# $Id: LDAP.pm,v 1.2 1999/10/10 15:04:03 tai Exp $
#

package Tie::LDAP;

=head1 NAME

 Tie::LDAP - Tie LDAP database to Perl hash.

=head1 SYNOPSIS

 use Tie::LDAP;

 tie %LDAP, 'Tie::LDAP', {
     host => $host, # LDAP hostname
     user => $user, # DN used to access LDAP database
     pass => $pass, # Password used with DN for access
     base => $base, # Base DN used for each/keys/values operation
 };

=head1 DESCRIPTION

This library allows you to tie LDAP database to simple hash.
Once tied, all hash operation will cause corresponding LDAP
operation, hopefully as expected.

Fetching data from tied hash will return hash reference to
named (by full DN) LDAP entry, which hold the attributes in
lowercase as a key, and the references to ARRAY holding
the real values as a value.

Storing data is as easy as fetching: just push hash reference
- with the same structure as fetched hash - back in.

Also, fetching/storing data into fetched hash reference will
work as expected - it will manipulate corresponding field in
fetched LDAP entry.

=cut

use strict;
use Carp;
use Net::LDAPapi;
use Tie::LDAP::Entry;

use vars qw($DEBUG $VERSION);

$DEBUG   = 0;
$VERSION = '0.02';

sub TIEHASH {
    my $name = shift;
    my $opts = shift;
    my $conn = new Net::LDAPapi($opts->{host} || 'localhost') || croak($@);
    my $mesg;

    print STDERR "[$name] TIEHASH\n" if $DEBUG;

    $conn->set_option(LDAP_OPT_SIZELIMIT, $opts->{maxsize} || 5000);
    $conn->set_option(LDAP_OPT_TIMELIMIT, $opts->{maxwait} || 5000);

    unless ($conn->bind_s($opts->{user}, $opts->{pass}) == LDAP_SUCCESS) {
        croak($conn->errstring);
    }
    bless { conn => $conn, base => $opts->{base} }, $name;
}

sub FETCH {
    my $self = shift;
    my $path = shift;
    my $conn = $self->{conn};
    my $mesg = $conn->search($path, LDAP_SCOPE_BASE, '(!(dn=))', [], 0);
    my $data = {};

    print STDERR "[$self] FETCH\n" if $DEBUG;
    print STDERR "[$self] FETCH - path: $path\n" if $DEBUG;

    return undef unless $mesg >= 0;
    return undef unless $conn->result($mesg, 0, -1) != -1;
    return undef unless $conn->first_entry;

    ##
    for (my $s = $conn->first_attribute; $s ; $s = $conn->next_attribute) {
        $data->{$s} = [$conn->get_values_len($s)];
    }
    $conn->msgfree;
    $conn->abandon($mesg);

    ##
    tie %{$data}, 'Tie::LDAP::Entry', {
        path => $path,
        data => { %{$data} },
        conn => $self->{conn},
    };
    return $data;
}

sub STORE {
    my $self = shift;
    my $path = shift;
    my $data = shift;

    print STDERR "[$self] STORE\n" if $DEBUG;

    $self->{conn}->delete_s($path);
    $self->{conn}->add_s($path, $data);
}

sub DELETE {
    my $self = shift;
    my $path = shift;

    print STDERR "[$self] DELETE\n" if $DEBUG;
    print STDERR "[$self] DELETE - path: $path\n" if $DEBUG;

    $self->{conn}->delete_s($path);
}

sub CLEAR {
    my $self = shift;
    my $path;

    print STDERR "[$self] CLEAR\n" if $DEBUG;

    $path = $self->FIRSTKEY || return;
    do {
        $self->DELETE($path);
    } while ($path = $self->NEXTKEY);
}

sub EXISTS {
    my $self = shift;
    my $path = shift;

    print STDERR "[$self] EXISTS\n" if $DEBUG;

    $self->FETCH($path);
}

sub FIRSTKEY {
    my $self = shift;
    my $conn = $self->{conn};
    my $path;

    print STDERR "[$self] FIRSTKEY\n" if $DEBUG;

    return undef unless $self->{base};

    $self->{mesg} = $conn->search($self->{base},
                                  LDAP_SCOPE_ONELEVEL, '(!(dn=))', [], 0);

    return undef if $self->{mesg} < 0;

    $self->NEXTKEY;
}

sub NEXTKEY {
    my $self = shift;
    my $last = shift;
    my $conn = $self->{conn};
    my $path;

    print STDERR "[$self] NEXTKEY\n" if $DEBUG;

    return undef unless $conn->result($self->{mesg}, 0, -1) != -1;
    return undef unless $conn->first_entry;

    $path = $conn->get_dn;

    print STDERR "[$self] NEXTKEY - path: $path\n" if $DEBUG;

    $conn->msgfree;
    $path;
}

sub DESTROY {
    my $self = shift;

    print STDERR "[$self] DESTROY\n" if $DEBUG;

    $self->{conn}->unbind;
}

=head1 BUGS

Doing each/keys/values operation to tied hash works, but could
be _very_ slow, depending on the size of the database.

Also, though this is not a bug, substituting empty array to
tied hash will cause whole database to be cleared out. I
might disable this feature since almost nobody would want
to see this happen anyway.

=head1 COPYRIGHT

Copyright 1998-1999, T. Yamada <tai@imasy.or.jp>.
All rights reserved.

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::LDAP>

=cut

1;

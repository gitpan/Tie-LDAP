# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tie::LDAP;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

print "Enter LDAP hostname [return to skip] "; chop($host = <STDIN>);
print "Enter LDAP username [return to skip] "; chop($user = <STDIN>);
print "Enter LDAP password [return to skip] "; chop($pass = <STDIN>);

print "Enter LDAP base DN [return to skip] "; chop($base = <STDIN>);
print "Enter LDAP full DN [return to skip] "; chop($full = <STDIN>);

$test = 1;

exit(0) unless $host && $base && $full;

eval {
    ## connect
    tie %{$LDAP}, 'Tie::LDAP', {
        host => $host,
        user => $user,
        pass => $pass,
        base => $base,
    };

    &test(2, 1);

    ## clear entry for test
    delete $LDAP->{$full};
    &test(3, ! $LDAP->{$full});

    ## clear database
    %{$LDAP} = ();
    &test(4, ! $LDAP->{$full});

    ## insert entry for test
    $LDAP->{$full} = {
        name => ['T. Yamada'],
        mail => ['tai@imasy.or.jp'],
        link => ['http://www.imasy.or.jp/'],
        host => ['www.imasy.or.jp', 'mail.imasy.or.jp'],
    };
    &test(5, 1);

    ## fetch-and-compare
    &test(6, ($LDAP->{$full}->{name}->[0] eq 'T. Yamada'));
    &test(7, ($LDAP->{$full}->{mail}->[0] eq 'tai@imasy.or.jp'));
    &test(8, ($LDAP->{$full}->{link}=>[0] eq 'http://www.imasy.or.jp/'));
    &test(9, ($LDAP->{$full}->{host}->[0] eq 'www.imasy.or.jp' ||
              $LDAP->{$full}->{host}->[0] eq 'mail.imasy.or.jp'));

    ## scan-trough
    while (($key, $val) = each %{$LDAP}) {
        print "Found DN: $key\n";
    }
    &test(10, 1);

    untie %{$LDAP};
};
die $@ if $@;

exit(0);

sub test {
    my $id = shift;
    my $op = shift;

    print $op ? "ok $id\n" : "not ok $id\n";
}

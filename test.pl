# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tie::LDAP;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

print "Enter LDAP hostname => "; chop($host = <STDIN>);
print "Enter LDAP username => "; chop($user = <STDIN>);
print "Enter LDAP password => "; chop($pass = <STDIN>);
print "Enter LDAP basename => "; chop($base = <STDIN>);
print "Enter LDAP fullname => "; chop($full = <STDIN>);

$test = 1;

eval {
    ## connect
    tie %{$LDAP}, 'Tie::LDAP', {
        host => $host,
        user => $user,
        pass => $pass,
        base => $base,
    };

    &test(2, 1);

    ## add
    $LDAP->{$full} = {
        name => ['T. Yamada'],
        mail => ['tai@imasy.or.jp'],
        link => ['http://www.imasy.or.jp/'],
        host => ['www.imasy.or.jp', 'mail.imasy.or.jp'],
    };
    &test(3, 1);

    ## fetch and compare
    &test(4, ($LDAP->{$full}->{name}->[0] eq 'T. Yamada'));
    &test(5, ($LDAP->{$full}->{mail}->[0] eq 'tai@imasy.or.jp'));
    &test(6, ($LDAP->{$full}->{link}=>[0] eq 'http://www.imasy.or.jp/'));
    &test(7, ($LDAP->{$full}->{host}->[0] eq 'www.imasy.or.jp' ||
              $LDAP->{$full}->{host}->[0] eq 'mail.imasy.or.jp'));

    untie %{$LDAP};
};
die $@ if $@;

exit(0);

sub test {
    my $id = shift;
    my $op = shift;

    print $op ? "ok $id\n" : "not ok $id\n";
}


WHAT IS IT
==========

This library will allow you to connect LDAP database to simple
Perl hashtable. Any reference/insertation to hash will cause
corresponding access to LDAP database automatically, hidden from
the programmer.

Also, LDAP entry returned by the hash access is tied with LDAP
database, too. Any hash operation to the returned hash will
also cause corresponding field of LDAP entry to be manipulated.

HOW TO INSTALL
==============

Just type:

    perl Makefile.PL
    make
    make install

and you should be all set. By the way, you might want to test this
before installation by

    make test

But you'll need working LDAP database which can be used for the test.

REQUIREMENT
===========

This module requires Net::LDAPapi.

Version 0.01 required Net::LDAP, but I had switched since then.

HOW TO USE
==========

For the usage, please consult POD document embedded in the library.
Also,

    perldoc Tie::LDAP

should show you the document if installed correctly.

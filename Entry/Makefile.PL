use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Tie::LDAP::Entry',
    'VERSION_FROM' => 'Entry.pm', # finds $VERSION
);

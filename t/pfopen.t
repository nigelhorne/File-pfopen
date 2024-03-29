#!perl

use strict;
use warnings;

use File::Spec;
use Test::Most tests => 22;
use Test::NoWarnings;
use Test::TempDir::Tiny;

use_ok('File::pfopen', ('pfopen'));

my $tmpdir = tempdir();
my $filename = File::Spec->catfile($tmpdir, 'pfopen.txt');
open(my $fout, '>', $filename);
print $fout "Hello, world\n";
close $fout;
ok(defined(pfopen($tmpdir, 'pfopen', 'txt')));
ok(defined(pfopen("/non-existent:$tmpdir", 'pfopen', 'txt')));
ok(defined(pfopen("/etc/group:$tmpdir", 'pfopen', 'txt')));
ok(!defined(pfopen($tmpdir, 'pfopen', 'bar')));
my $fh;
($fh, $filename) = pfopen($tmpdir, 'pfopen', 'bar:txt');
ok(<$fh> eq "Hello, world\n");
ok($filename =~ /pfopen\.txt$/);
$fh = pfopen($tmpdir, 'pfopen', 'txt:baz');
ok(<$fh> eq "Hello, world\n");
ok(!defined(pfopen('/', 'pfopen', 'txt')));
ok(defined(pfopen("/:$tmpdir", 'pfopen', 'bar:txt')));
($fh, $filename) = pfopen("/:$tmpdir", 'pfopen', 'bar:txt');
ok(<$fh> eq "Hello, world\n");
ok($filename =~ /pfopen\.txt$/);
$fh = pfopen("/:$tmpdir", 'pfopen', 'bar:txt');
ok(<$fh> eq "Hello, world\n");
ok(!defined(pfopen('/', 'pfopen', 'txt')));
ok(!defined(pfopen("/:$tmpdir", 'pfopen')));
ok(defined(pfopen($tmpdir, 'pfopen.txt')));
($fh, $filename) = pfopen("/:$tmpdir", 'pfopen.txt');
ok(<$fh> eq "Hello, world\n");
ok($filename =~ /pfopen\.txt$/);
$fh = pfopen("/:$tmpdir", 'pfopen.txt');
ok(<$fh> eq "Hello, world\n");

($fh, $filename) = pfopen("/:/not_there_tulip:$tmpdir", 'pfopen.txt');
ok(<$fh> eq "Hello, world\n");
ok($filename =~ /pfopen\.txt$/);

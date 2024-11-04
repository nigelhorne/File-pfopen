#!perl

use strict;
use warnings;

use Cwd;
use File::Spec;
use Test::Most tests => 28;
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

# Mock data
my $test_dir = getcwd();
$filename = File::Spec->catfile($test_dir, 'testfile.txt');

# Set up a test file to read
open($fh, '>', $filename) or die "Could not create test file: $!";
print $fh "Sample text\n";
close $fh;

# Open file without suffix in scalar context
{
	my $fh = pfopen($test_dir, 'testfile', undef);
	ok(!defined $fh, "Don't open file without suffix in scalar context");
}

# Open file with suffix in scalar context
{
	my $fh = pfopen($test_dir, 'testfile', 'txt');
	ok(defined $fh, 'Opened file with suffix in scalar context');
	close $fh if $fh;
}

# Open file without suffix in list context
{
	my ($fh, $rc) = pfopen($test_dir, 'testfile', undef);
	ok((!defined $fh) && (!defined $rc),  "Don't open file without suffix in list context");
	close $fh if $fh;
}

# Open file with suffix in list context
{
	my ($fh, $rc) = pfopen($test_dir, 'testfile', 'txt');
	ok((defined $fh) && (defined $rc), 'Opened file with suffix in list context');
	cmp_ok($rc, 'eq', $filename, 'Filename was as expected');
	close $fh if $fh;
}

# File not found returns undef
{
	my $fh = pfopen($test_dir, 'nonexistentfile', undef);
	ok(!defined $fh, 'Returns undef when file is not found');
}

# Clean up
unlink $filename;

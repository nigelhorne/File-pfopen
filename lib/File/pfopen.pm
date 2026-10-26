package File::pfopen;

# Author Nigel Horne: njh@bandsman.co.uk
# Copyright (C) 2017-2026 Nigel Horne

# Usage is subject to licence terms.
# The licence terms of this software are as follows:
# Personal single user, single computer use: GPL2
# All other users (including Commercial, Charity, Educational, Government)
#	must apply in writing for a licence for use from Nigel Horne at the
#	above e-mail.

use strict;
use warnings;
use Carp;
use Config;
use File::Spec;

require Exporter;
our @ISA = ('Exporter');
our @EXPORT_OK = ('pfopen');

=head1 NAME

File::pfopen - Try hard to find a file

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 SUBROUTINES/METHODS

=head2 pfopen

Look in a list of directories for a file with an optional list of suffixes.

    use File::pfopen 'pfopen';
    ($fh, $filename) = pfopen('/tmp:/var/tmp:/home/njh/tmp', 'foo', 'txt:bin');
    $fh = pfopen('/tmp:/var/tmp:/home/njh/tmp', 'foo', undef, '<');
    $fh = pfopen(['/tmp', '/var/tmp'], 'foo', 'txt');

The list of directories is either a string separated by the platform's
path separator (C<$Config{path_sep}>, which is ':' on UNIX and ';' on Windows,
as used by the PATH environment variable),
or a reference to an array of directories.
On Windows, this allows directories with drive letters to be given,
for example C<'C:\tmp;D:\data'>.

The list of suffixes is separated by colons on all platforms.

If mode (argument 4) isn't given, the file is open read/write ('+<').
Only file modes are accepted ('<', '>', '>>', '+<', '+>' and '+>>',
optionally followed by I/O layers such as ':raw'),
so a found file can never be run as a command.

Only files are found, never directories.
Empty or undefined directories in the list are ignored,
as are names containing a NUL character, which can't be valid filenames.

Returns the file handle, or in list context the file handle and the filename.
Returns nothing if the file isn't found.

Croaks if the path or prefix is missing,
if the path is a reference to something other than an array,
or if the mode is invalid.

=cut

sub pfopen
{
	my ($path, $prefix, $suffixes, $mode) = @_;

	if((!defined($path)) || (!defined($prefix)) || (length($prefix) == 0)) {
		croak('Usage: pfopen($path, $prefix, [$suffixes, [$mode]])');
	}
	if(ref($path) && (ref($path) ne 'ARRAY')) {
		croak('pfopen: path must be a string or an array reference');
	}

	$mode ||= '+<';	# defaults to opening RW

	# Allowing other modes would let '-|' or '|-' run the found file as a command
	if($mode !~ /\A\+?(?:<|>>?)(?::.*)?\z/s) {
		croak("pfopen: invalid mode '$mode'");
	}

	# A NUL can never be in a filename, so don't bother looking.
	#	It would only give warnings from the file tests
	return if(index($prefix, "\0") >= 0);
	return if(defined($suffixes) && (index($suffixes, "\0") >= 0));

	my @dirs = grep { defined($_) && length($_) && (index($_, "\0") < 0) }
		(ref($path) ? @{$path} : split(/\Q$Config{path_sep}\E/, $path));

	# NUL can't appear in a filename, so different arguments can't give the same key
	my $candidate = join("\0", $prefix, defined($suffixes) ? $suffixes : '', @dirs);
	our $savedpaths;

	# Return cached filename if available
	if(my $rc = $savedpaths->{$candidate}) {
		# $self->_log({ message => "remembered $savedpaths->{$candidate}" });
		if((!-d $rc) && open(my $fh, $mode, $rc)) {
			return wantarray ? ($fh, $rc) : $fh;
		}
		delete $savedpaths->{$candidate};	# Failed to open cached file
	}

	foreach my $dir (@dirs) {
		next unless -d $dir;

		foreach my $suffix (defined($suffixes) ? split(/:/, $suffixes) : undef) {
			my $rc = File::Spec->catfile($dir, defined $suffix ? "$prefix.$suffix" : $prefix);

			# Opening a directory with '<' succeeds, but it isn't what was asked for
			next if(-d $rc);
			next unless -r _;

			# $self->_log({ message => "using $rc" });

			# FIXME: Doesn't play well in taint mode
			open(my $fh, $mode, $rc) or next;

			$savedpaths->{$candidate} = $rc;
			return wantarray ? ($fh, $rc) : $fh;
		}
	}

	return;
}


=head1 BUGS

Doesn't play well in taint mode.

Would be better if the mode and suffixes options were the other way around, but it's too late to change that now.

Please report any bugs or feature requests to C<bug-file-pfopen at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-pfopen>.
I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc File::pfopen

You can also look for information at:

=over 4

=item * MetaCPAN

L<https://metacpan.org/release/File-pfopen>

=item * RT: CPAN's request tracker

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=File-pfopen>

=item * CPANTS

L<http://cpants.cpanauthors.org/dist/File-pfopen>

=item * CPAN Testers' Matrix

L<http://matrix.cpantesters.org/?dist=File-pfopen>

=item * CPAN Testers Dependencies

L<http://deps.cpantesters.org/?module=File::pfopen>

=back

=head1 AUTHOR

Nigel Horne, C<< <njh at nigelhorne.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2017-2026 Nigel Horne.

Usage is subject to the GPL2 licence terms.
If you use it,
please let me know.

=cut

1;

package File::pfopen;

# Author Nigel Horne: njh@bandsman.co.uk
# Copyright (C) 2017-2023 Nigel Horne

# Usage is subject to licence terms.
# The licence terms of this software are as follows:
# Personal single user, single computer use: GPL2
# All other users (including Commercial, Charity, Educational, Government)
#	must apply in writing for a licence for use from Nigel Horne at the
#	above e-mail.

use strict;
use warnings;
use File::Spec;

require Exporter;
our @ISA = ('Exporter');
our @EXPORT_OK = ('pfopen');

=head1 NAME

File::pfopen - Try hard to find a file

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SUBROUTINES/METHODS

=head2 pfopen

Look in a list of directories for a file with an optional list of suffixes.

    use File::pfopen 'pfopen';
    ($fh, $filename) = pfopen('/tmp:/var/tmp:/home/njh/tmp', 'foo', 'txt:bin');
    $fh = pfopen('/tmp:/var/tmp:/home/njh/tmp', 'foo');

=cut

sub pfopen {
	my $path = shift;
	my $prefix = shift;
	my $suffixes = shift;

	our $savedpaths;

	my $candidate;
	if(defined($suffixes)) {
		$candidate = "$prefix;$path;$suffixes";
	} else {
		$candidate = "$prefix;$path";
	}
	if($savedpaths->{$candidate}) {
		# $self->_log({ message => "remembered $savedpaths->{$candidate}" });
		my $rc = $savedpaths->{$candidate};
		open(my $fh, '+<', $rc);
		if(wantarray) {
			return ($fh, $rc);
		}
		return $fh;
	}

	foreach my $dir(split(/:/, $path)) {
		next unless(-d $dir);
		if($suffixes) {
			foreach my $suffix(split(/:/, $suffixes)) {
				# $self->_log({ message => "check for file $dir/$prefix.$suffix" });
				my $rc = File::Spec->catfile($dir, "$prefix.$suffix");
				if(-r $rc) {
					$savedpaths->{$candidate} = $rc;
					# FIXME: Doesn't play well in taint mode
					open(my $fh, '+<', $rc);
					if(wantarray) {
						return ($fh, $rc);
					}
					return $fh;
				}
			}
		} elsif(-r "$dir/$prefix") {
			my $rc = File::Spec->catfile($dir, $prefix);
			$savedpaths->{$candidate} = $rc;
			# $self->_log({ message => "using $rc" });
			open(my $fh, '+<', $rc);
			if(wantarray) {
				return ($fh, $rc);
			}
			return $fh;
		}
	}
	return();
}

=head1 AUTHOR

Nigel Horne, C<< <njh at bandsman.co.uk> >>

=head1 BUGS

Doesn't play well in taint mode.

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

=head1 LICENSE AND COPYRIGHT

Copyright 2017-2023 Nigel Horne.

Usage is subject to licence terms.

The licence terms of this software are as follows:

* Personal single user, single computer use: GPL2
* All other users (including Commercial, Charity, Educational, Government)
  must apply in writing for a licence for use from Nigel Horne at the
  above e-mail.

=cut

1;

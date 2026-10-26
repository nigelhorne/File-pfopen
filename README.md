[![Linux Build Status](https://travis-ci.org/nigelhorne/File-pfopen.svg?branch=master)](https://travis-ci.org/nigelhorne/File-pfopen)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/1t1yhvagx00c2qi8?svg=true)](https://ci.appveyor.com/project/nigelhorne/cgi-info)
[![Dependency Status](https://dependencyci.com/github/nigelhorne/File-pfopen/badge)](https://dependencyci.com/github/nigelhorne/File-pfopen)
[![Coverage Status](https://coveralls.io/repos/github/nigelhorne/File-pfopen/badge.svg?branch=master)](https://coveralls.io/github/nigelhorne/File-pfopen?branch=master)
[![Kritika Analysis Status](https://kritika.io/users/nigelhorne/repos/7983554719636717/heads/master/status.svg)](https://kritika.io/users/nigelhorne/repos/7983554719636717/heads/master/)

# NAME

File::pfopen - Try hard to find a file

# VERSION

Version 0.04

# SUBROUTINES/METHODS

## pfopen

Look in a list of directories for a file with an optional list of suffixes.

    use File::pfopen 'pfopen';
    ($fh, $filename) = pfopen('/tmp:/var/tmp:/home/njh/tmp', 'foo', 'txt:bin');
    $fh = pfopen('/tmp:/var/tmp:/home/njh/tmp', 'foo', undef, '<');
    $fh = pfopen(['/tmp', '/var/tmp'], 'foo', 'txt');

The list of directories is either a string separated by the platform's
path separator (`$Config{path_sep}`, which is ':' on UNIX and ';' on Windows,
as used by the PATH environment variable),
or a reference to an array of directories.
On Windows, this allows directories with drive letters to be given,
for example `'C:\tmp;D:\data'`.

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

# BUGS

Doesn't play well in taint mode.

Would be better if the mode and suffixes options were the other way around, but it's too late to change that now.

Please report any bugs or feature requests to `bug-file-pfopen at rt.cpan.org`,
or through the web interface at
[http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-pfopen](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-pfopen).
I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc File::pfopen

You can also look for information at:

- MetaCPAN

    [https://metacpan.org/release/File-pfopen](https://metacpan.org/release/File-pfopen)

- RT: CPAN's request tracker

    [https://rt.cpan.org/NoAuth/Bugs.html?Dist=File-pfopen](https://rt.cpan.org/NoAuth/Bugs.html?Dist=File-pfopen)

- CPANTS

    [http://cpants.cpanauthors.org/dist/File-pfopen](http://cpants.cpanauthors.org/dist/File-pfopen)

- CPAN Testers' Matrix

    [http://matrix.cpantesters.org/?dist=File-pfopen](http://matrix.cpantesters.org/?dist=File-pfopen)

- CPAN Testers Dependencies

    [http://deps.cpantesters.org/?module=File::pfopen](http://deps.cpantesters.org/?module=File::pfopen)

# AUTHOR

Nigel Horne, `<njh at nigelhorne.com>`

# LICENCE AND COPYRIGHT

Copyright 2017-2026 Nigel Horne.

Usage is subject to the GPL2 licence terms.
If you use it,
please let me know.

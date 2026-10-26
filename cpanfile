# Generated from Makefile.PL using makefilepl2cpanfile

requires 'perl', '5.6.2';

requires 'Carp';
requires 'Config';
requires 'Exporter';
requires 'File::Spec';

on 'test' => sub {
	requires 'Readonly';
	requires 'Test::DescribeMe';
	requires 'Test::Memory::Cycle';
	requires 'Test::Mockingbird', '0.14';
	requires 'Test::Most';
	requires 'Test::Returns', '0.05';
	requires 'Test::Needs';
	requires 'Test::NoWarnings';
	requires 'Test::TempDir::Tiny';
	requires 'Test::Warnings';
};

on 'develop' => sub {
	requires 'Devel::Cover';
	requires 'Perl::Critic';
	requires 'Test::Pod';
	requires 'Test::Pod::Coverage';
};

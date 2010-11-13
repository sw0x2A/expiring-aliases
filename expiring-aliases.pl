#!/usr/bin/env perl

use strict;
use warnings;
use DBI;

my $dbuser = "user";
my $dbpass = "pass";
my $dbname = "mail";

my $today     = date(0);
my $yesterday = date(-1);

my $dsn = "DBI:mysql:$dbname";
my $dbh = DBI->connect( $dsn, $dbuser, $dbpass, { RaiseError => 1 } )
  or die "Could not connect to database: " . DBI->errstr;

my $sth = $dbh->prepare( "SELECT username, userrealm FROM virtual_users" );
$sth->execute();

while ( my ( $username, $userrealm ) = $sth->fetchrow_array() ) {
	my $alias_today     = "$username-EXPIRES-$today\@$userrealm";
	my $alias_yesterday = "$username-EXPIRES-$yesterday\@$userrealm";
	my $recipient       = "$username\@$userrealm";

	update_alias( $alias_today, $alias_yesterday )
	  or insert_alias( $alias_today, $recipient );
}
$sth->finish;

delete_alias("%-EXPIRES-$yesterday\@%");

$dbh->disconnect()
  or warn "Could not disconnect from database: " . $dbh->errstr;

###############################################################################
sub update_alias {
###############################################################################
	my ( $alias_today, $alias_yesterday ) = @_;
	return $dbh->do( "
		UPDATE virtual_aliases SET alias = $alias_today 
		WHERE alias = $alias_yesterday
	" );
}

###############################################################################
sub insert_alias {
###############################################################################
	my ( $alias_today, $recipient ) = @_;
	return $dbh->do( "
		INSERT INTO virtual_aliases ( alias, recipients ) 
		VALUES( $alias_today, $recipient )
	" );
}

###############################################################################
sub delete_alias {
###############################################################################
	my ($expired_aliases) = @_;
	return $dbh->do( "
		DELETE FROM virtual_aliases 
		WHERE alias LIKE $expired_aliases
	" );
}

###############################################################################
sub date {
###############################################################################
	my ($day) = @_;
	my ( $year, $mon, $mday ) = ( localtime( time + $day * 86400 ) )[ 5, 4, 3 ];
	return sprintf( "%04d%02d%02d", $year + 1900, $mon + 1, $mday );
}

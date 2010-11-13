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
my $dbh = DBI->connect( $dsn, $dbuser, $dbpass )
  or die "Could not connect to database: " . DBI->errstr;

my $sql = 'SELECT username, userrealm FROM virtual_users';
my $sth = $dbh->prepare($sql)
  or die "Could not prepare statement: " . $dbh->errstr;
$sth->execute()
  or die "Could not execute statement: " . $dbh->errstr;

while ( my @virtual_users = $sth->fetchrow_array() ) {
	my ( $username, $userrealm ) = @virtual_users;
	my $alias_today     = "$username-EXPIRES-$today\@$userrealm";
	my $alias_yesterday = "$username-EXPIRES-$yesterday\@$userrealm";
	my $recipient       = "$username\@$userrealm";
	
	update_alias( $dbh, $alias_today, $alias_yesterday )
	  or insert_alias( $dbh, $alias_today, $recipient );
}

$sth->finish;

delete_alias( $dbh, "%-EXPIRES-$yesterday\@%" );

$dbh->disconnect();

###############################################################################
sub update_alias {
###############################################################################
	my ( $dbh, $alias_today, $alias_yesterday ) = @_;
	my $sql = 'UPDATE virtual_aliases SET alias = ? WHERE alias = ?';
	my $sth = $dbh->prepare($sql)
	  or die "Could not prepare statement: " . $dbh->errstr;
	$sth->execute( $alias_today, $alias_yesterday )
	  or die "Could not execute statement: " . $dbh->errstr;
	my $rows = $sth->rows;
	$sth->finish;
	return $rows;
}

###############################################################################
sub insert_alias {
###############################################################################
        my ( $dbh, $alias_today, $recipient ) = @_;
	my $sql = 'INSERT INTO virtual_aliases ( alias, recipients ) VALUES( ?, ? )';
	my $sth = $dbh->prepare($sql)
	  or die "Could not prepare statement: " . $dbh->errstr;
	$sth->execute( $alias_today, $recipient )
	  or die "Could not execute statement: " . $dbh->errstr;
	$sth->finish;
}

###############################################################################
sub delete_alias {
###############################################################################
        my ( $dbh, $expired_aliases ) = @_;
        my $sql = 'DELETE FROM virtual_aliases WHERE alias LIKE ?';
        my $sth = $dbh->prepare($sql)
          or die "Could not prepare statement: " . $dbh->errstr;
        $sth->execute($expired_aliases)
          or die "Could not execute statement: " . $dbh->errstr;
	$sth->finish;
}

###############################################################################
sub date {
###############################################################################
	my $day = shift;
	my ( $year, $mon, $mday ) = ( localtime( time + $day * 86400 ) )[ 5, 4, 3 ];
	$mon  += 1;
	$year += 1900;
	return sprintf( "%04d%02d%02d", $year, $mon, $mday );
}



--
-- Table structure for table `virtual_aliases`
--

CREATE TABLE `virtual_aliases` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `alias` varchar(255) default NULL,
  `recipients` text,
  PRIMARY KEY  (`id`),
  FULLTEXT KEY `aliases` (`alias`,`recipients`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Postfix virtual recipient aliases';

--
-- Table structure for table `virtual_mailbox_domains`
--

CREATE TABLE `virtual_mailbox_domains` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `domain` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  FULLTEXT KEY `domains` (`domain`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Postfix virtual domains';

--
-- Table structure for table `virtual_users`
--

CREATE TABLE `virtual_users` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `username` varchar(255) NOT NULL,
  `userrealm` varchar(255) NOT NULL,
  `userpassword` varchar(255) NOT NULL,
  `auth` tinyint(1) default '1',
  `active` tinyint(1) default '1',
  `email` varchar(255) NOT NULL default '',
  `virtual_uid` smallint(5) default '1000',
  `virtual_gid` smallint(5) default '1000',
  `virtual_mailbox` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `recipient` (`email`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='SMTP AUTH and virtual mailbox users';


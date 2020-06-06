#! /usr/bin/env perl
use strict;
use warnings;
use POSIX qw(strftime);
my $date = strftime ("%Y%m%d", localtime);

# This file contains the settings for the 60m data collecting script

print "Loading Settings........\r\n";



#Database info
our $db_server = "";
our $db_user = "";
our $db_pass = "";
our $db_database = "";

#Log Files
our $run_log = "run.log";
our $error_log = "error.log";

#Datafile location
our $data_file = "/home/pi/.local/share/JS8Call/DIRECTED.TXT";

our $Reciever = '';


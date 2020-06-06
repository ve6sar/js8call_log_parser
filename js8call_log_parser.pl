#!/usr/bin/perl
# Version 1.1 Check date of last insert so we don't dupilcate entries and speed up the processing 
# Version 1.2 Add distance calculation

use lib '/home/admin/perl5/lib/perl5/';

use strict;
use warnings;
use Data::Dumper;
use DBI;
use Time::Piece;
use Ham::Locator;
use Math::Trig qw(great_circle_direction rad2deg deg2rad);
use GIS::Distance;


print "\n\nJS8Call log parser V1.2\r\n";
print "\nWritten by Sean VE6SAR for the auroralpower.ca 60m Beacon Project\r\n";

require '/home/pi/scripts/settings.pl'; #Our settings file
#Declare the variables from the config file
our $Receiver;
our $db_server;
our $db_user;
our $db_pass;
our $db_database;
our $run_log;
our $error_log;
our $data_file;

#open(STDOUT, '>>', $run_log) or die "Can't open log";
open(STDERR, '>>', $error_log) or die "Can't open log";

my $n = 0; #For counting number of packets processed
my $dbTable;
my $dateformat = "%Y-%m-%d %H:%M:%S";

# Connect to the Database
print "Connecting to Database $db_database.....\r\n";
my $driver = "mysql";
my $dsn = "DBI:mysql:database=$db_database;host=$db_server";
my $dbh = DBI->connect($dsn, $db_user, $db_pass );
if(!$dbh){
 die "failed to connect to MySQL database DBI->errstr()";
}else{
 print("Connected to MySQL server successfully.\n");
}

#Get the list of beacon stations 
my $sqlList = "SELECT * FROM `Stations`"; #Select Stations
my $sth = $dbh->prepare($sqlList);
$sth->execute() or die $DBI::errstr;
my @row;
my %stationGrids;
my $regex; 
my @regex_a;

while (@row = $sth->fetchrow_array) {  # retrieve one row
  push @{ $stationGrids{$row[1]} }, $row[1], $row[2];
}

$sth->finish();

foreach my $regex1 (sort (keys %stationGrids)) {
  push (@regex_a, $stationGrids{$regex1}[0]);
}

$regex = join '|', @regex_a; #format the regex for filtering

print "\nRegistered Beacon Stations:\r\n";
print map { "$_ => $stationGrids{$_}[1]\n\r" } keys %stationGrids;

#Get time stamp from the last db record
my $sqlLast = "SELECT * FROM `js8Report` WHERE `Receiver` = '$Receiver' ORDER BY `TimeStamp` DESC LIMIT 1"; #Select Stations
$sth = $dbh->prepare($sqlLast);
$sth->execute() or die $DBI::errstr;
my $last;
while (@row = $sth->fetchrow_array) {  # retrieve one row
  $last = $row[1];
}
$sth->finish();
print "\n\rLast report in DB => $last \r\n";

chomp $last;
my $dateLast = Time::Piece->strptime($last, $dateformat); 

#Open the log file to parse 
open (LOG, $data_file) or die $!;
print"\n\rOpening Log File....\r\n";

 
while(<LOG>){
  my @line = split(/\t/,$_);
  my @call = split(/:/,$line[4]);  

  chomp $line[0];  
  my $dateLine = Time::Piece->strptime($line[0], $dateformat);
  
  if ($regex =~ /$call[0]/ && $dateLine > $dateLast) {  #Check for registered station and insert into db
 
    #Get bearing and distance
    print "Transmiter => $stationGrids{$call[0]}[1]\r\n";
    print "Receiver =>   $stationGrids{$Receiver}[1]\r\n";	 
	 my %grids = conGrid ($stationGrids{$call[0]}[1], $stationGrids{$Receiver}[1]);    
    
    print "Time Stamp: $line[0]\r\n";
    print "Report:     $line[3]\r\n";  
    print "Station:    $call[0]\r\n";
	    
    my $sql = "INSERT INTO `js8Report` (
  													`TimeStamp`,
  													`SignalLevel`,
  													`Station`,
  													`Receiver`,
  													`Distance`,
  													`Bearing`
  													) VALUES (
  													'$line[0]',
  													'$line[3]',
  													'$call[0]',
  													'$Receiver',
  													'$grids{distance}', 
  													'$grids{degrees}');";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    print "Inserting into Database.....\r\n";
    $sth->finish();
    
    $n++;    
    print "$n entries added to Database\r\n";    
    print "**********\r\n";
   
    }        			
}
close (LOG);        			
print "Total entries added $n \r\n";

#get lat long and dist/bearing and output a hash
sub conGrid {
            	my %latlong;
		my $m = new Ham::Locator;
            	$m->set_loc($_[0]);
		($latlong{senderLat}, $latlong{senderLong}) = $m->loc2latlng;
            	$m->set_loc($_[1]);
            	($latlong{receiverLat}, $latlong{receiverLong}) = $m->loc2latlng;
			
		print "Sender Lat/Long => $latlong{senderLat}, $latlong{senderLong}\r\n";
		print "Receiver Lat/Long => $latlong{receiverLat}, $latlong{receiverLong}\r\n";		
		
		#Calculate the distance and bearing and add it to the hash
		my $gis = GIS::Distance->new();	
		$latlong{distance} = $gis->distance( $latlong{senderLat},$latlong{senderLong} => $latlong{receiverLat},$latlong{receiverLong} );
		$latlong{distance} = sprintf("%.0f", $latlong{distance});		
		print "Distance => $latlong{distance} km\r\n";	
	
		#Calculate the initial bearing
		my @L = NESW( $latlong{senderLong}, $latlong{senderLat});
    	my @T = NESW( $latlong{receiverLong}, $latlong{receiverLat});
		my $rad = great_circle_direction(@L, @T); #returns the bearing in radians
		print "Radians => $rad\r\n";		
		$latlong{degrees}  = sprintf("%.0f", rad2deg($rad));
		print "Degrees => $latlong{degrees}\r\n";		 
		 
		return %latlong;	
	}
	
writeLog($n);

#Convert degrees to rads
sub NESW { deg2rad($_[0]), deg2rad(90 - $_[1]) }

sub writeLog { 
  print "Writing to log....\r\n\r\n";
  my $datetime = localtime();  
  open (my $fhl, '>>', '/home/pi/scripts/logs/js8callparse.log') or die "Could not open file '/home/pi/scripts/logs/js8callparse.log' $!";
  print $fhl "$datetime js8call log file parsed $_[0] entries added to DB\r\n";
  print $fhl "\r\n";
  close $fhl;
}


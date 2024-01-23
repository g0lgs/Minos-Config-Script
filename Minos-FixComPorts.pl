#!/usr/bin/env perl

# Script to update Minos Radio Comport configuration based on Identified
# 20 Feb 2021 by Stewart Wilkinson G0LGS

# Note: Minos is sensitive to changes to the config files and
# will reject the file if the case of values are changed
# therefore the radio definitions must match exactly

# Requires libconfig-inifiles-perl

use warnings;
use strict;
use Config::IniFiles;
use File::stat;
use Getopt::Long qw(VersionMessage :config no_auto_abbrev );
use Pod::Usage qw(pod2usage);

my($VERBOSE)=0;
my($QUIET)=0;
my($ExitVal)=0;

my($CfgPath)= '/home/g0lgs/runtime/Configuration';

# Get command options
if( ! GetOptions (
	'V|VERBOSE+'	=> \$VERBOSE,
	'Q|QUIET'	=> sub { $QUIET=1; $VERBOSE=0; },
	'cfg=s'		=> \$CfgPath,
) ) {
	pod2usage( { -message => "Wrong or Missing Paramaters!\n", -verbose => 0} );
	exit 1;
}

my($IniPath) = $CfgPath. '/Radio/AvailRadio.ini';

if( ! -f $IniPath ){
	printf STDERR "ERROR: %s was not found\n", $IniPath unless($QUIET);
	exit 1;
}

# Get File Owner
my $gid = stat($IniPath)->gid;
my $uid = stat($IniPath)->uid;

my $MinosIni = Config::IniFiles->new(-file => $IniPath );

# Define Radios expected in Minos
my %Radios = ();
$Radios{"IC-9700"}= { 'port' => '/dev/ic9700a'};
$Radios{"IC-7300"}= { 'port' => '/dev/ic7300'};

foreach my $radio (keys %Radios) {
	
	if( defined $Radios{$radio}{'port'} ){

		my $port = $Radios{$radio}{'port'};
		printf "Checking %s link as %s\n", $radio, $port if($VERBOSE);

		# Does the defined /dev/name symlink exist ?
		if ( -e $port ) {
			printf "Found %s\n", $port if($VERBOSE);
			# read the link
			my $ComPort = readlink $port;
			if( $ComPort ) {
				printf "\tas %s\n", $ComPort if($VERBOSE);
				if ($MinosIni->exists($radio, 'comport')) {
					if( $MinosIni->setval($radio, 'comport', $ComPort ) ){
						printf "Updated port for %s OK\n", $radio if($VERBOSE);
					}else{
						printf "WARNING: Failed to update port for %s\n", $radio if($VERBOSE);
					}
				} else {
					printf "WARNING: No Minos Radio defined for %s\n", $radio if($VERBOSE);
				}
			}
		}else{
			printf "No %s found.\n", $port if($VERBOSE);
		}
	}else{
		printf STDERR "ERROR: port not defined for Radio %s\n", $radio unless($QUIET);
		$ExitVal++;
	}
}

$MinosIni->RewriteConfig();

# Restore Owner
chown $uid, $gid, $IniPath;

exit $ExitVal;

__END__

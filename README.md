# Radio-Config-Scripts

by Stewart (G0LGS)

Purpose
-------

To update the Minos Radio Configuration file 
~/runtime/Configuration/Radio/AvailRadio.ini to point to the correct /dev/ttyUSB<n> 
device for any number of connected Radio's

Configuration
-------------

You will need to connect each Radio individually to the USB and use the udevadm command like:

	sudo udevadm info -a /dev/ttyUSB0
or
	sudo udevadm info -a -n ttyUSB0

Examine the details so you can correctly populate the UDEV Rule file '99-hamlib.rules' with the details of 
your radio's

	From the udevam output you will need:

	ATTRS{idVendor}		(probably '10c4')
	ATTRS{idProduct}	(probably 'ea60')
	ATTRS{serial}		(may include the radio model and an identifying serial)

Each Radio Needs a unique name for each port so that the MinosSetRadoPorts Script can associate them with 
the configured Radios

The example '99-hamlib.rules':

	# Create symlinks for USB ports for Specific Radio's

	# IC 7300
	KERNEL=="ttyUSB?" SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{serial}=="IC-7300 03011354", SYMLINK+="ic7300" RUN{program}+="/usr/loc	al/sbin/MinosSetRadioPorts -cfg /home/g0lgs/runtime/Configuration -Q &"

	# IC 9700
	KERNEL=="ttyUSB?" SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{serial}=="IC-9700 13001015 A", SYMLINK+="ic9700a" RUN{program}+="/usr/	local/sbin/MinosSetRadioPorts -cfg /home/g0lgs/runtime/Configuration -Q &"
	KERNEL=="ttyUSB?" SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{serial}=="IC-9700 13001015 B", SYMLINK+="ic9700b"

	# Create Consistent Names for Sound (Codec) devices based on the USB port that device is connected
	# This makes it easier to configure apps that use Sound Devices provided that you always use the same USB port / Hub combination
	ACTION=="change", SUBSYSTEM=="sound", DEVPATH=="/devices/*/usb*/sound/card?", ENV{PULSE_NAME}="$env{ID_ID}.$env{ID_PATH_TAG}"

As anything invoked by udev rules are run as 'root' you will need to correctly set the Path to your Minos runtime 
configuration folder using the -cfg parameter in the RUN options above.

Currently you will also need to Modifiy MinosSetRadioPorts to set the correct Paths and Radio IDs as configured in 
Minos and matching /dev/<name> as assigned by the custom udev rules

	my %Radios = ();
	$Radios{"IC-9700"}= { 'port' => '/dev/ic9700a'};
	$Radios{"IC-7300"}= { 'port' => '/dev/ic7300'};


Installation
------------

Place the '99-hamlib.rules' file in /etc/udev/rules.d/

	sudo cp -f 99-hamlib.rules /etc/udev/rules.d/

Place the MinosSetRadioPorts in /usr/local/sbin

	sudo cp -f MinosSetRadioPorts /usr/local/sbin
	sudo chmod 744 /usr/local/sbin/MinosSetRadioPorts


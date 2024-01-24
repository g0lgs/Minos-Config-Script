# Radio-Config-Scripts

Purpose

To update the Minos Radio Configuration file ~/runtime/Configuration/Radio/AvailRadio.ini to point to the correct /dev/ttyUSB<n> device for any number of connected Radio's

Configuration

You will need to connect each Radio individually and use the udevadm command like:

	udevadm info -a /dev/ttyUSB0 | less

or

	udevadm info -a -n ttyUSB0 | less

to examine the details so you cna populate the UDEV Rule file '99-hamlib.rules'  (placed in /etc/udev/rules.d/) with the details of your radio's

You will need ATTRS{idVendor} (10c4 for Icom Radios) and ATTRS{idProduct} and ATTRS{serial}

Each Radio Needs a unique Symlink so that the Minos-FixComPorts.pl Script can associate them with the configured Radios


# Create symlinks for USB ports for Specific Radio's (G0LGS Feb 2021)
# IC 7300
KERNEL=="ttyUSB?" SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{serial}=="IC-7300 03011354", SYMLINK+="ic7300" RUN+="/usr/local/sbin/Minos-FixComPorts.pl -Q &"
# IC 9700
KERNEL=="ttyUSB?" SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{serial}=="IC-9700 13001015 A", SYMLINK+="ic9700a" RUN+="/usr/local/sbin/Minos-FixComPorts.pl -Q &"
KERNEL=="ttyUSB?" SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTRS{serial}=="IC-9700 13001015 B", SYMLINK+="ic9700b"

ACTION=="change", SUBSYSTEM=="sound", DEVPATH=="/devices/*/usb*/sound/card?", ENV{PULSE_NAME}="$env{ID_ID}.$env{ID_PATH_TAG}"


You will also need to Modifiy Minos-FixComPorts.pl to set the correct Paths and Radio IDs


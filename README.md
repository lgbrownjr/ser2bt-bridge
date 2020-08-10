# ser2bt-bridge
## Serial to Bluetooth bridge for raspberry pi zero

### Introduction:
This is a set of scripts, that allow a user to connect to a raspberry pi zero wh to a serial device (cisco switch), then allow the user to connect to it via serial over bluetooth, and then the pi will bridge the two connections to form a single console from the users pc to the switch without having wires laying on the flooe.

This is probably better to use this than ser2net as a lot of environments will not allow multiple metwork connections to a given device at the same time, so a given laptop could connect to the pi via ip, but would loose access to corperate/govornemt resources while they work.

Bluetooth over serial is better as allows a given laptop with these restrictions to still connect to the switches console port while still being connected to the corperate/govornemt resources without violating any rules - or voilating fewer rules... :)

## Installation:
### Pre-requasites:
##### Base:
In order to get the service to work, without a UPS backup, or status screen, perform the following:
 - Add the code in the .bashrc_addendum at the end of the file on your .bashrc file located in your home directory.
 
#### So in its base configuration, one only needs the following files:
- bashrc_addendom - to add launch the ser2bt_bridge utility once a user logs using rfcomm (serial over bluetooth.
- rfcomm.service - Launches a service that will listed for incomming connection requests from the rfcomm vty port.
- ser2bt_bridge script - checks to make sure there is a valid connection on rfcomm and either the vtyusb or vtyamc0, and attempts to bridge them together.

#### You also need a:
- micro usb to usb A female cable to connect to a usb to serial cable.
- Micro usb to usb A male to connect from the switch to the Raspberry Pi's power port.
- Some cheap case to house the pi.

### Options - to add a little polish to the bridge:
- For battary backup, attatcg a upslite.
- For status and helth updates, attatch a waveshare.2.13 e-paper display.
- Add additional scripts to monitor the battery's capacity, and to drive the waveshare display.


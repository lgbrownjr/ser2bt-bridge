# ser2bt-bridge
## Serial to Bluetooth bridge for raspberry pi zero
### Introduction:
This is a set of scripts, that allow a user to connect to a raspberry pi zero wh to a serial device (Cisco switch), then allow the user to connect to it via serial over bluetooth, and then the pi will bridge the two connections to form a single console from the users pc to the switch without having wires laying on the floor.

This is probably better to use this than ser2net as a lot of environments will not allow multiple metwork connections to a given device at the same time, so a given laptop could connect to the pi via ip, but would loose access to corporate/government resources while they work.

Bluetooth over serial is better as allows a given laptop with these restrictions to still connect to the switches console port while still being connected to the corporate/government resources without violating any rules - or violating fewer rules... :)
## Installation:
### Base:
The following steps will guide you through the process getting this system to work from just after everything is unboxed, to the point where this works in its base form - that is the raspberry pi zero, by itself acting as a bluetooth to serial bridge.  We will be using headless installation method, so you will not need a keyboard, mouse, or monitor.
#### Pre-requisites:
In order to get the service to work, without any of the two options: UPS backup, or status screen, you will need:  
- raspberry pi zero w, or if you want to expand without having to solder, raspberry pi zero wh.
- an SD card with a minimum of 8G.  Actually, you can get smaller, but for the price, 8G or 16G is a good choice.
- a USB micro to USB type A for power.
- a USB micro to USB type A Female to connect to a type A to RF45 serial cable to connect to a Cisco rj45 console port.
- a USB mini to USB micro to connect to most Cisco switch USB console ports.
- A case for said raspberry pi.
#### OS installation and setup:
- insert the SD card into a different computer to perform the first few steps:
  - Download link is [here](https://www.raspberrypi.org/downloads/raspberry-pi-os/).
  - Follow Raspbian’s directions [here](https://www.raspberrypi.org/documentation/installation/installing-images/README.md).
- Eject and re-insert the SD card, and use your PC's file explorer to open the SD card - should be called boot.
  - Add the following to the end of the first line in /boot/cmdline.txt:
    - modules-load=dwc2,g_serial
  - Save and close cmdline.txt
- Save and close /boot/cmdline.txt
- Add or uncomment the following settings in the /boot/config.txt file:  
    `enable_uart=1`
    
    `dtoverlay=dwc2`
- Save and close `/boot/config.txt`
- Create an empty file and call it `ssh` - no extensions, just `ssh`.
- Create another file called `wpa_supplicant.conf`, and open it:
  - Insert the following:
  ```bash
  ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
  update_config=1
  country=US
  
  network={
      ssid="SSID"
      psk="passphrase/password"
      key_mgmt=WPA-PSK
  }
  ```
You are now done with this section, safely eject the SD card, and insert it into you raspberry pi zero.
##### First login:
- Power on the Pi, and give it about a minute to boot.
 - Using your favorite SSH client, login into your pi: `pi@<[hostname|IP Address]>`, where *hostname*, or *IP Address* are = to your Pi's.

**Note: Finding the IP address can be painful unless you have a utility on your PC or phone that can scan the network for active devices.  Recommend trying the hostname first.**

##### Update OS:
```bash
sudo apt update && sudo apt full-upgrade -y
```
- Reboot your Pi when the upgrade is complete.
##### Additional OS Setup:
- Setup using raspi-config:
  - Change *Default Password*.
  - Under *Network Options:*
    - Disable *Waiting for network on boot*.
    - Change hostname.
  - Under *Interfacing Options:*
    - Enable SSH.
    - Enable serial.
  - Under *localization Options:*
    - Setup locals.
    - Set timezone on the Pi.
    - Keyboard (optional).
  - Under *Advanced Options:*
    - Select *Memory Split* and set *GPU memory* to 16MB.
  - Under the main menu, select *exit*, and if it asks you to reboot, do so.
##### Pre-Requisites:
- Add the following commands to the terminal:
```bash
    sudo echo "dwc2" | sudo tee -a /etc/modules
    sudo echo "g_serial" | sudo tee -a /etc/module
```
 - Install the following software:
 ```bash
 sudo apt install screen git minicom tio m4 rfkill xterm
 ```
- Open the file: /etc/systemd/system/dbus-org.bluez.service:

`sudo nano /etc/systemd/system/dbus-org.bluez.service`
  - Add `-C` to the end of:`ExecStart=/usr/lib/bluetooth/bluetoothd`, so:
  
    `ExecStart=/usr/lib/bluetooth/bluetoothd`

    Becomes:

    `ExecStart=/usr/lib/bluetooth/bluetoothd -C`
- Then, right below that, add the following configurations:
```bash
    ExecStartPost=/usr/bin/sdptool add SP'
    ExecStartPost=/bin/hciconfig hci0 piscan
```
  - Save and close `/etc/systemd/system/dbus-org.bluez.service`
##### Create the following Directories & download the scripts:
```bash
    mkdir /home/pi/Projects/
    sudo mkdir /usr/local/lib/ser2bt-bash
```
- In the Projects folder, initialize git, and clone the following repository:
```bash
   cd $HOME/Projects
   git init
   git clone https://github.com/lgbrownjr/ser2bt-bridge.git
```
- Copy files to their respective locations:
```bash
   cd ser2bt-bridge/
   sudo cp ser2bt_bridge /usr/local/bin/
   cat bashrc_addendum.sh >> ~/.bashrc
   sudo cp rfcomm.service /etc/systemd/system/
```
##### Enable services:
```bash
   sudo systemctl enable rfcomm
   sudo systemctl enable getty@ttyGS0.service
   sudo systemctl daemon-reload
   sudo systemctl restart bluetooth.service	
   sudo service rfcomm enable
```
##### Bluetooth setup:
- Open `/etc/bluetooth/main.conf`

`sudo nano /etc/bluetooth/main.conf`
  - Uncomment and/or change the following settings:
    - `DiscoverableTimeout = 0`
    - `PairableTimeout = 0`
  - Save and close `/etc/bluetooth/main.conf`
- type in `sudo bluetoothctl`, and press enter.
  - You should see *Agent Registered*, then a prompt.
  - Type in `show`
  - You are looking for two items in the output:
	- Powered: yes
	- Discoverable: Yes
	- Pairable: Yes
  - If all 3 items match with what is on your screen, then type `exit` and skip over the rest of the bluetooth section.
  - Otherwise, type in the following:
```sh
    power on
    discoverable on
    pairable on
```
  - Type in `show` to verify, then `exit` to leave bluetooth control
##### We're Done!
If everything went as planned, your raspberry pi zero should be acting like a serial to bluetooth bridge, allowing you to connect to a switches console port via bluetooth from your computer.
- Now, reboot your raspberry pi zero.
- After the raspberry pi has rebooted, use your PC/laptop to pair with it.  The Pi should advertise that it supports serial communications, so you'll be able to associate it with your PC/laptops com/ttyUSBx/ttyACMx ports.
- Once that's done, go ahead and open your favorite terminal program, and pint it to the com/ttyUSBx/tty/ACMx port, and set it up to connect at 9600 bps, n/8/1, xterm.
### Installation of ups-lite & waveshare e-ink screen:
Coming Shortly.

 
#### So in its base configuration, one only needs the following files:
- bashrc_addendom - to add launch the ser2bt_bridge utility once a user logs using rfcomm (serial over bluetooth.
- rfcomm.service - Launches a service that will listed for incoming connection requests from the rfcomm vty port.
- ser2bt_bridge script - checks to make sure there is a valid connection on rfcomm and either the vtyUSB or vtyamc0, and attempts to bridge them together.
#### You also need a:
- micro USB to USB A female cable to connect to a USB to serial cable.
- Micro USB to USB A male to connect from the switch to the Raspberry Pi's power port.
- Some cheap case to house the pi.
### Options - to add a little polish to the bridge:
- For battery backup, attach a ups-lite.
- For status and system health updates, attach a waveshare.2.13 e-paper display.
- Add additional scripts to monitor the battery's capacity, and to drive the waveshare display.

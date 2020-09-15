# ser2bt-bridge
## Serial to Bluetooth bridge for raspberry pi zero

### Introduction:
This is a set of scripts, that allow a user to connect to a raspberry pi zero wh to a serial device (cisco switch), then allow the user to connect to it via serial over bluetooth, and then the pi will bridge the two connections to form a single console from the users pc to the switch without having wires laying on the floor.

This is probably better to use this than ser2net as a lot of environments will not allow multiple metwork connections to a given device at the same time, so a given laptop could connect to the pi via ip, but would loose access to corperate/govornemt resources while they work.

Bluetooth over serial is better as allows a given laptop with these restrictions to still connect to the switches console port while still being connected to the corperate/govornemt resources without violating any rules - or voilating fewer rules... :)

## Installation:
### Base:
The following steps will guide you through the process getting this system to work from just after everything is unboxed, to the point where this works in its base form - that is the raspberry pi zero, by itslef acting as a bluetooth to serial bridge.  We will be using headless installation method, so you will not need a keyboard, mouse, or monitor.
#### Pre-requasites:
In order to get the service to work, without any of the two options: UPS backup, or status screen, you will need:  
- raspberry pi zero w, or if you want to expand without having to solder, raspberry pi zero wh.
- an SD card with a minimum of 8G.  Actually, you can get smaller, but for the price, 8G or 16G is a good choice.
- a USB micro to USB type A for power.
- a USB micro to USB type A Female to connect to a type A to RF45 serial cable to connect to a cisco rj45 console port.
- a USB mini to USB micro to connect to most cisco switch usb console ports.
- A case for said raspberry pi.
#### OS installation and setup:
- insert the SD card into your computer to perform the fist few steps:
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

You are now done with this section, safely eject the SD card, and insert it into you raspberry pi zero
- Update OS:

```bash
sudo apt update && sudo apt full-upgrade -y
```

- Setup using raspi-config:
  - Change *Default Password*.
  - Under *Network Options:*
    - Disable *Waiting for network on boot*
    - Change hostname.
  - Under *Interfacing Options:*
    - Enable SSH.
    - Enable serial
  - Under *localization Options:*
    - Setup locals.
    - Set timezone on the Pi.
    - Keyboard (optional).
  - Under *Advanced Options:*
    - Select *Memory Split* and set gpu memory to 16MB.
- Add the following commands to the terminal:

```bash
    sudo echo "dwc2" | sudo tee -a /etc/modules
    sudo echo "g_serial" | sudo tee -a /etc/module
```
 - Install the following software:
 
 ```bash
 sudo apt install screen git minicom tio m4 rfkill xterm
 ```
- In the file:/etc/systemd/system/dbus-org.bluez.service
`sudo nano /etc/systemd/system/dbus-org.bluez.service`
  - Add `-C` to the end of:`ExecStart=/usr/lib/bluetooth/bluetoothd`, so:
  
    `ExecStart=/usr/lib/bluetooth/bluetoothd`

    Becomes:

    `ExecStart=/usr/lib/bluetooth/bluetoothd -C`
- Then, right below that, add:
```bash
    ExecStartPost=/usr/bin/sdptool add SP'
    ExecStartPost=/bin/hciconfig hci0 piscan
```

  - Save and close `/etc/systemd/system/dbus-org.bluez.service`
- Enable the getty@ttyGS0 service:
```bash
    sudo systemctl enable getty@ttyGS0.service
    sudo systemctl daemon-reload
    sudo systemctl restart bluetooth.service
```
Create the following Directories
```bash
    mkdir /home/pi/Projects/
    sudo mkdir /usr/local/lib/ser2bt
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
  - Copy the rfcomm service to `/systemd/system/` directory and enable the service
```bash
    sudo systemctl enable rfcomm
    sudo systemctl daemon-reload
    sudo service rfcomm enable
```
- Open `/etc/bluetooth/main.conf`

`sudo nano /etc/bluetooth/main.conf`
  - Uncomment and/or change the following settings:
    - `DiscoverableTimeout = 0`
    - `PairableTimeout = 0`
  - Save and close `/etc/bluetooth/main.conf`
- Now, reboot your raspberry pi zero.
  

 
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


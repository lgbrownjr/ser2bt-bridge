# ser2bt-bridge
## Serial to Bluetooth bridge for raspberry pi zero
### Introduction:
This project a set of scripts, that allow one to use the raspberry pi to "bridge" two serial connections together - one being a bluetooth link from a user to the pi, and the other being a serial connection to a device, such as a Cisco router or switch.  This allows the administrator manage the device while enjoying the benefit of being some distance away from it.

Unfortunately, there are many work environments that do not take kindly to raspberry pi's being on their network, and for some environments that simple act would almost certainly cause a resume generating event for the offending administrator.  Bluetooth over serial is better direction as allows a given laptop with these restrictions to still connect to a switches console port wirelessly.

Another benefit of using Bluetooth is that you don't have to worry about finding its IP address, you just open a putty serial connection, and presto, you are connected.
#### How it works at a high level:
Once you complete the installation, one would need to pair their laptop to it, during that process, a com port is assigned to the paired raspberry pi.  Usually, that is saved in a profile, so that going forward, one just needs to open thir favourite terminal program, and select their "bt serial" profile, and they're connected.

From there, the pi will determin if you are attatching to it via bluetooth, and since you are, it will try to determin if the pi is connected serially to a device, or not.  If the Pi is, it will "bridge" you through, using GNU screen.  If not, the pi will politly let you know, and exit to the bash terminal.

Some things to think about while you are happily administering your switch, router, or whatever.  If you are using that devices USB for power, and decide to reboot it, your pi will most likely un-graciously reboot as well.  This is not good as your pi's sd card will eventaully become corrupted, and stop working.  There are two ways around this:
1. Add a battery backup, to allow the pi to weather those reboots:  One of the options is to attatch a ups_lite.  This will allow the pi to be moved around between closets, or devices without powering it down, and back up.
2. Turn on *Overlay FS*.  This basically, turns your PI's sd card into a read only drive, so the risk of corrupting your sd card goes way, way down.  The down side is that you need to turn *Overlay FS* Off to update it or save files, then turn it back on.  Still testing this feature to see how well it works over the long run.

Finally, once done, pres <CTRL> + A, then \ to exit GNU Screen, then `sudo poweroff -p` to properly shut the bridge down.

## Installation:
Before we begin, please understand that everything in this repository is a work in progress...  :)
### Base:
The following steps will guide you through the process getting this system to work from just after everything is unboxed, to the point where this works in its base form - that is the raspberry pi zero, by itself acting as a bluetooth to serial bridge.  We will be using headless installation method, so you will not need a keyboard, mouse, or monitor.
#### Parts neeeded for this phase:
In order to get the service to work, without any of the two options: UPS backup, or status screen, you will need:  
- A Raspberry Pi Zero *W* - at a minimum, but if you don't like soldering, and have at least a desire to expand, get the Raspberry Pi Zero *WH* instead
- An SD card with a minimum of 8G.  Actually, you can get smaller, but for the price, 8G or 16G is a good choice.
- A USB micro to USB type A for power.  [Example](https://www.amazon.com/6in-Micro-USB-Cable-6-inches/dp/B003YKX6WM/ref=sr_1_18?dchild=1&keywords=usb+micro+to+usb+a+male+6+inch+uart+cable&qid=1599147190&s=electronics&sr=1-18)
- A USB micro to USB type A Female to connect to a USB type A to RF45 serial cable to connect to a Cisco rj45 console port.  USB to RJ45 [Example](https://www.amazon.com/gp/product/B01AFNBC3K/ref=ppx_yo_dt_b_asin_title_o07_s00?ie=UTF8&psc=1); micro to type A [example](https://www.amazon.com/UGREEN-Adapter-Samsung-Controller-Smartphone/dp/B00LN3LQKQ/ref=sr_1_2?dchild=1&keywords=usb%2Bmicro%2Bto%2Busb%2Ba%2Bfemale%2Bcable&qid=1599146495&s=electronics&sr=1-2&th=1).
- A Micro USB (Pi side) to Mini USB (switch side) to connect between the raspberry pi's serial port to the switches serial port.  Here is an [example](https://www.amazon.com/gp/product/B018M8YNDG/ref=ox_sc_act_title_1?smid=ATVPDKIKX0DER&psc=1)
- A case to house the pi.  Check this [example](https://www.amazon.com/Flirc-Raspberry-Pi-Zero-Case/dp/B08837L144/ref=sr_1_11_sspa?dchild=1&keywords=raspberry+pi+zero+battery+hat&qid=1600716473&sr=8-11-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUE0V0NONk1LS0hLNEEmZW5jcnlwdGVkSWQ9QTA5ODgwMDExTzgzV1hIVUxSQVJEJmVuY3J5cHRlZEFkSWQ9QTAxMTk0NDQySzdKM0UwV1FESTdBJndpZGdldE5hbWU9c3BfbXRmJmFjdGlvbj1jbGlja1JlZGlyZWN0JmRvTm90TG9nQ2xpY2s9dHJ1ZQ==) out for a good example, slightly pricey, but in my opinion, worth the cost.
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

##### Update OS and install dependencies:
```bash
 sudo apt update && sudo apt full-upgrade -y
 sudo apt install screen git minicom tio rfkill xterm -y
 ```
- Reboot your Pi when the upgrade is complete.
##### Additional OS Setup:
- Setup using raspi-config `sudo raspi-config`:
  - Under the main menu, select *Change User Password*.
  - Select*Network Options:*
    - Disable *Waiting for network on boot*.
    - Change hostname.
    - Select *Back*
  - Select *Interfacing Options:*
    - Enable SSH.
    - Enable serial.
    - Select *Back*
  - Select *localization Options*, and verify, or set:
    - Setup locals.
    - Set timezone on the Pi.
    - Keyboard (optional).
    - Select *Back*
  - Select *Advanced Options:*
    - Select *Memory Split* and set *GPU memory* to 16MB.
    - Select *Back*
  - Under the *Main Menu*, select *finish*, and if it asks you to reboot, do so.
##### Pre-Requisites to software installation:
- Add the following commands to the terminal:
```bash
    sudo echo "dwc2" | sudo tee -a /etc/modules
    sudo echo "g_serial" | sudo tee -a /etc/module
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
- Create the following Directories:
```bash
    mkdir /home/pi/Projects/
    sudo mkdir /usr/local/lib/ser2bt-bash
```
##### Download and setup the serial to bluetooth scripts:
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
The addition of am e-paper screen and ups backup will allow you to continue providing power to the Pi while not being plugged into a power source, and to easiliy tell the status of the bridge (Pi) without having to login to tell:
#### Psrts needed for this phase:
- For battery backup, attach a [ups-lite](https://www.ebay.com/itm/UPS-Lite-for-Raspberry-Pi-Zero-/352888138785).
- For status and system health updates, attach a [waveshare.2.13 e-paper](https://www.waveshare.com/2.13inch-e-Paper-HAT.htm) display.

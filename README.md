# ser2bt-bridge
## Serial to Bluetooth bridge for raspberry pi zero
Before we begin, please understand that everything in this repository is a work in progress...  :)  Especially as of 9/22/20, my documentation is still trying to keep up with what is working...  :)
### Introduction:
This project a set of scripts and libraries, that allow one to use a raspberry pi zero w to "bridge" two serial connections together - one being a bluetooth link from a user to the pi, and the other being a serial connection to a device, such as a Cisco router or switch.  This allows the administrator to manage the device while enjoying the benefit of of not having to tethered right up to it.

#### How it works at a high level:
After completing the installation and setup, one would need to pair their laptop to it and then assign a com/tty port to the bridge. Usually, that is saved to a profile within your favourate terminal program (Secure CRT, Putty, etc), so going forward, connecting to the brisge is extremely easy, reguardless of operating system your computer using.

Afer attaching to the bridge, it will determine if you are connecting to it via bluetooth, and since you are, it will then attempt to determine if the pi is also connected serially to a device.  If the Pi is connected, it will "bridge" you through.  If not, the pi will politely let you know, and exit to the bash terminal.

Some things to think about while you are happily administering your switch, router, or whatever:  If you are using that devices USB to ppower your bridge, and decide to reboot the connected device, your pi will most likely un-gracefully reboot along with it.  This is not good as your pi's SD card will eventually become corrupted, and stop working.  There are two ways around this:
1. Add a battery backup, to allow the pi to weather those reboots.  This will allow the pi to be moved around between closets, or devices without powering it down, and back up.  See below for more details.
2. Turn on *Overlay FS*.  This basically, turns your PI's sd card into a read only drive, so the risk of corrupting your SD card goes way, way down.  The down side is that you need to turn *Overlay FS* Off to update it or save files, then turn it back on.  I'm till testing this feature to see how well it works over the long run.

Finally, once done, press `<CTRL>` + `A`, then `\` to exit GNU Screen, then `sudo poweroff -p` to properly shut the bridge down.

## Setup:
### Base setup:
The following steps will guide you through the process getting this system to work from just after everything is unboxed, to the point where this works in its base form - that is the raspberry pi zero, by itself acting as a bluetooth to serial bridge.  We will be using headless installation method, so you will not need a keyboard, mouse, or monitor.
#### Parts needed for this phase:
In order to get the service to work, without any of the two options: UPS backup, or status screen, you will need:  
- A Raspberry Pi Zero *W* - at a minimum, but if you don't like soldering, and have at least a desire to expand, get the Raspberry Pi Zero *WH* instead
- An SD card with a minimum of 8G.  Actually, you can get smaller, but for the price, 8G or 16G is a good choice.
- A USB micro to USB type A for power.  [Example](https://www.amazon.com/6in-Micro-USB-Cable-6-inches/dp/B003YKX6WM/ref=sr_1_18?dchild=1&keywords=usb+micro+to+usb+a+male+6+inch+uart+cable&qid=1599147190&s=electronics&sr=1-18)
- A USB micro to USB type A Female to connect to a USB type A to RJ45 serial cable to connect to a Cisco RJ45 console port.  USB to RJ45 [Example](https://www.amazon.com/gp/product/B01AFNBC3K/ref=ppx_yo_dt_b_asin_title_o07_s00?ie=UTF8&psc=1); micro to type A [example](https://www.amazon.com/UGREEN-Adapter-Samsung-Controller-Smartphone/dp/B00LN3LQKQ/ref=sr_1_2?dchild=1&keywords=usb%2Bmicro%2Bto%2Busb%2Ba%2Bfemale%2Bcable&qid=1599146495&s=electronics&sr=1-2&th=1).
- A Micro USB (Pi side) to Mini USB (switch side) to connect between the raspberry pi's serial port to the switches serial port.  Here is an [example](https://www.amazon.com/gp/product/B018M8YNDG/ref=ox_sc_act_title_1?smid=ATVPDKIKX0DER&psc=1)
- A case to house the pi.  Check this [example](https://www.amazon.com/Flirc-Raspberry-Pi-Zero-Case/dp/B08837L144/ref=sr_1_11_sspa?dchild=1&keywords=raspberry+pi+zero+battery+hat&qid=1600716473&sr=8-11-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUE0V0NONk1LS0hLNEEmZW5jcnlwdGVkSWQ9QTA5ODgwMDExTzgzV1hIVUxSQVJEJmVuY3J5cHRlZEFkSWQ9QTAxMTk0NDQySzdKM0UwV1FESTdBJndpZGdldE5hbWU9c3BfbXRmJmFjdGlvbj1jbGlja1JlZGlyZWN0JmRvTm90TG9nQ2xpY2s9dHJ1ZQ==) out for a good example, slightly pricey, but in my opinion, worth the cost.
#### Installation:
##### OS installation and setup:
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
###### First login:
- Power on the Pi, and give it about a minute to boot.
 - Using your favorite SSH client, login into your pi: `pi@<[hostname|IP Address]>`, where *hostname*, or *IP Address* are = to your Pi's.

**Note: Finding the IP address can be painful unless you have a utility on your PC or phone that can scan the network for active devices.  Recommend trying the hostname first.**

###### Update OS and install dependencies:
```bash
 sudo apt update && sudo apt full-upgrade -y
 ```
 
 ```bash
 sudo apt install screen git minicom tio rfkill xterm -y
 ```
- Reboot your Pi when the upgrade is complete.
###### Additional OS Setup:
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
###### Pre-Requisites to software installation:
- Add the following commands to the terminal:
```bash
    sudo echo "dwc2" | sudo tee -a /etc/modules
    sudo echo "g_serial" | sudo tee -a /etc/modules
```
- Open the file: /etc/systemd/system/dbus-org.bluez.service:

`sudo nano /etc/systemd/system/dbus-org.bluez.service`
  - Add `-C --noplugin=sap` to the end of:`ExecStart=/usr/lib/bluetooth/bluetoothd`, so:
  
    `ExecStart=/usr/lib/bluetooth/bluetoothd`
    
    Becomes:

    `ExecStart=/usr/lib/bluetooth/bluetoothd -C --noplugin=sap`
- Then, right below that, add the following configurations:
```bash
    ExecStartPost=/usr/bin/sdptool add SP
    ExecStartPost=/bin/hciconfig hci0 piscan
```
  - Save and close `/etc/systemd/system/dbus-org.bluez.service`
- Create the following Directories:
```bash
    mkdir -p /home/pi/Projects/support/
    sudo mkdir /usr/local/lib/ser2bt-bridge/
```
###### Download and setup the serial to bluetooth scripts:
- In the Projects folder, initialize git, and clone the following repository:
```bash
   cd $HOME/Projects/
   git init
   git clone https://github.com/lgbrownjr/ser2bt-bridge.git
```
- Copy files to their respective locations:
```bash
   cd ser2bt-bridge/
   sudo cp ser2bt_bridge /usr/local/bin/
   sudo cp rfcomm.service /etc/systemd/system/
   sudo cp format.sh /usr/local/lib/
   sudo cp ser2bt_bridge.screenrc /etc/
```
- Add configurations to your `.bashrc`:
```bash
   cat bashrc_addendum.sh >> ~/.bashrc
```
###### Enable services:
```bash
   sudo systemctl enable rfcomm
   sudo systemctl daemon-reload
   sudo systemctl restart bluetooth.service	
```
###### Resolve serial bug (preventing the pi from shutting down and/or rebooting):
```bash
   sudo mkdir -p /etc/systemd/system/getty@ttyGS0.service.d
   sudo bash -c 'echo -e "[Service]\nTTYReset=no\nTTYVHangup=no\nTTYVTDisallocate=no" > /etc/systemd/system/getty@ttyGS0.service.d/override.conf'
   sudo systemctl daemon-reload
   sudo systemctl enable getty@ttyGS0.service
```

###### Bluetooth setup:
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
###### We're Done!
If everything went as planned, your raspberry pi zero should be acting like a serial to bluetooth bridge, allowing you to connect to a switches console port via bluetooth from your computer.
- Now, reboot your raspberry pi zero.
- After the raspberry pi has rebooted, use your PC/laptop to pair with it.  The Pi should advertise that it supports serial communications, so you'll be able to associate it with your PC's com/ttyUSBx/ttyACMx ports.
- Once that's done, go ahead and open your favorite terminal program, and point it to the com/ttyUSBx/tty/ACMx port, and set it up to connect at 9600 bps, n/8/1, xterm.
### Extended setup:
#### Installation of *ups-lite* & *waveshare e-ink screen*:
The addition of am e-paper screen and ups backup will allow you to continue providing power to the Pi while not being plugged into a power source, and to easily tell the status of the bridge (Pi) without having to login to check.
#### Parts needed for this phase:
- For battery backup, attach a [ups-lite](https://www.ebay.com/itm/UPS-Lite-for-Raspberry-Pi-Zero-/352888138785).
- For status and system health updates, attach a [waveshare.2.13 e-paper](https://www.waveshare.com/2.13inch-e-Paper-HAT.htm) display.
#### Installation:
Coming soon:
## Known Bugs:
- With respect to full installation, I can't get the services to load in a manner where the e-paper screen does not wake up soon enough in the boot sequence.  In face, What I have done seems to have slowed down the booting of the pi.  Stability, and functionality are not impacted, its just that it takes 40 seconds for the pi to completely boot - and start the status screen.
- For some reason, while connected via bluetooth, one cannot update the OS, or githib repositories.  A workaround, is to open a `screen` session, tehn perform any update taskes.  Another workaround would be to ssh into it as well...
## Improvements:
- Build an installation script to automate most of the installation steps.
- Update the scripts to support USB micro to multiple serial ports to support connectivity to more than one switch at a time.
- I'm not sure if this even doable, but attempt to allow multiple concurrent bluetooth connections, esxpecially if the item listed above is completed.
- Continue testing *Overlay FS* as a means to protect the SD cards from corruption.

Again, will be constantly updating the documentation, so check back for more.

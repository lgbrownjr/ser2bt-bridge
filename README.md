# ser2bt-bridge
## Serial to Bluetooth bridge for raspberry pi zero w
Before we begin, understand that everything in this repository is a work in progress...  :) 
### Definitions:
I tend to use several different discripters for each piece thats involved with this project, so I've tried to define them below to helpkeep the reader from being confused.. :)
- For the purpose of this project, the terms *slave* refers to a router or switch.  However, anything with a console port can be used  such as a server, appliance, Firewall, Wireless LAN Conroller, etc will work as well.
- The terms *master*  refers to the PC, laptop, phone, or tablet.
- The terms *pi*, *bridge*, *ser2bt* all refer to the *raspberry pi zero w*, and is being used as a *bridge* to connect *master* with *slave*.
- The terms *user*, *you*, *network engineer*, *network administrator*, *administrator*, or *engineer* all refer to the person using this *bridge* to connect the link between it, and the *master*, and it and the *slave*.
### Preamble:
This project is a set of scripts, services and libraries, that allow one to connect to a *raspberry pi zero w* from their phone/tablet/laptop using a serial/bluetooth connection, then be "bridged" over a usb to console connection to a switch/router/etc.  This allows the network/system engineer to manage devices via a console port, while enjoying the benefit of not having to be tethered right up to it.
#### How it works at a high level:
These scripts and services basicaly utilize screen and rfcomm to make the connection between a laptop/phone/etc, and the router or switch you are trying to connect to.  The connection between your
After completing the installation and setup, one will need to pair their laptop to the pi and then assign it to a com/tty port. This is a one time (per device) process, so going forward, connecting to the brisge is extremely easy, reguardless of the operating system your computer using.

Afer connecting to the bridge via bluetooth, it will attempt to determine if the pi is also connected serially to a device.(swich/router/etc)  If so, the pi will "bridge" you through to the device.  If not, the pi will politely let you know, and exit to the bash terminal.

If you connect to the bridge via ssh or standard telnet, it will assume you have logged in for maintenance, or any other purpose, and not attempt to bridge you through to the end device.

If you connect to the bridge via telnet using the ser2net special ports, then you will be automatically "bridged" in with the connected end device.

If you login using bluetooth, and are successfully connected to an end device (switch, router, etc), the pi will automatically begin logging your session.  Logs are sent to `~/console_logging/` and are timestamped.
Finally, once done, press `<CTRL>` + `A`, then `\` to exit *GNU screen*, then `sudo poweroff` to properly shut the bridge down.
### Considerations:
Some things to think about while you are happily administering your switch, router, or whatever:
#### Security:
By design, this bridge does not have security in mind, preferring instead to focus on easy discovery, pairing, and connectivity to allow the network administrator to focus on getting their work done.  
##### Security features turned off:
- When pairing a new laptop for the fist time, no pin is required.
- When connecting to the bridge over bluetooth, the administrator will be auto logged-in as pi.
- Telnet is installed and is used for bridging to serial connections via ser2net - more about that below:
#### Power:
If you are relying on that end device's USB port to ppower your bridge, and decide to reboot it, your pi will most likely be un-gracefully powercycled along with it.  This is not good as your pi's SD card will eventually become corrupted, and stop working all-to-gether.  There are two possible ways around this:
1. Add a battery backup, to allow the pi to weather those pesky, but necessary.  This will allow the pi to be moved around between closets, or devices without powering it down, and back up.  See below for more details.
2. Turn on *Overlay FS*.  This basically, turns your pi's sd card into a read only drive, so the risk of corrupting your SD card goes way, way down.  The down side is that you need to turn *Overlay FS* Off to update it or to make configuration adjustments, then turn it back on.  I'm till testing this feature to see how well it works over the long run.
#### Reconnecting:
If you disconnect from the pi, and want to reconnect, do not try to use the terminal program's(putty, secureCRT,etc) *reconnect* feature.  Close the window, and then re-open.
#### Screen size:
You will notice simetimes that if after you adjust the size of youre terminal programs window, the colums and rows will not automatically adjust as they do for ssh.  The fix is to type the command *resize* to force the pi to adjust to the new terminal window size.
#### Updates, or any network-related traffic:
If you want to conduct any updates, or use of tools that require the use of the network on your pi while connected using bluetooth, use *screen*, then perform updates or use any tools that require network access.  The reason is that they simply don't work otherwise.  I am working on a solution though.
#### Accurate time:
I don't think i have to get into why we need accurate time - even on this pi.  The only way it works now is to attatch it to a wifi network, such as your hotspot so that it can obtain time.  The use of a battery-powered RTC board would also help, and reduce the need to connect you're pi to a network.  In the instructions below, 
## Setup:
There are two different setup options, basic, and full.
- Basic should be used if you are only using a pi, and do not wish (at this point) to add a screen, or an external battery.
- Full should be used if you are using the pi, along with the e-ink display, and an external UPS.
### Basic setup:
The following steps will guide you through the process getting this system to work from just after everything is unboxed, to the point where you are connecting to a switch, router, or whatever - that is the raspberry pi zero, by itself acting as a bluetooth to serial bridge.  We will be using headless installation method, so you will not need a keyboard, mouse, or monitor.
#### Parts needed for Basic setup:
You will need:
- A *raspberry pi zero w* - at a minimum, but if you don't like soldering, and have at least a desire to expand, get the *raspberry pi zero wh* instead.
- An SD card with a minimum size of 8G.  Actually, you can get smaller, but for the price, 8G or 16G is a good choice.
- A USB micro to USB type A for power.  [Example](https://www.amazon.com/6in-Micro-USB-Cable-6-inches/dp/B003YKX6WM/ref=sr_1_18?dchild=1&keywords=usb+micro+to+usb+a+male+6+inch+uart+cable&qid=1599147190&s=electronics&sr=1-18)
- A USB micro to USB type A Female to connect to a USB type A to RJ45 serial cable to connect to a Cisco RJ45 console port.  USB to RJ45 [Example](https://www.amazon.com/gp/product/B01AFNBC3K/ref=ppx_yo_dt_b_asin_title_o07_s00?ie=UTF8&psc=1); micro to type A [example](https://www.amazon.com/UGREEN-Adapter-Samsung-Controller-Smartphone/dp/B00LN3LQKQ/ref=sr_1_2?dchild=1&keywords=usb%2Bmicro%2Bto%2Busb%2Ba%2Bfemale%2Bcable&qid=1599146495&s=electronics&sr=1-2&th=1).
- A Micro USB (Pi side) to Mini USB (switch side) to connect between the raspberry pi's usb port to the switches USB-console port.  Here is an [example](https://www.amazon.com/gp/product/B018M8YNDG/ref=ox_sc_act_title_1?smid=ATVPDKIKX0DER&psc=1)
- A case to house the pi.  Check this [example](https://www.amazon.com/Flirc-Raspberry-Pi-Zero-Case/dp/B08837L144/ref=sr_1_11_sspa?dchild=1&keywords=raspberry+pi+zero+battery+hat&qid=1600716473&sr=8-11-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUE0V0NONk1LS0hLNEEmZW5jcnlwdGVkSWQ9QTA5ODgwMDExTzgzV1hIVUxSQVJEJmVuY3J5cHRlZEFkSWQ9QTAxMTk0NDQySzdKM0UwV1FESTdBJndpZGdldE5hbWU9c3BfbXRmJmFjdGlvbj1jbGlja1JlZGlyZWN0JmRvTm90TG9nQ2xpY2s9dHJ1ZQ==) out for a good example, slightly pricey, but in my opinion, worth the cost.
#### Installation:
##### OS installation and setup:
- insert the SD card into a different computer to perform the first few steps:
  - Download link is [here](https://www.raspberrypi.org/downloads/raspberry-pi-os/).
  - Follow Raspbian’s directions [here](https://www.raspberrypi.org/documentation/installation/installing-images/README.md).
- Eject and re-insert the SD card, and use your PC's file explorer to open the SD card - should be called *boot*.
  - Add the following to the end of the first line in the `/boot/cmdline.txt` file:
    - modules-load=dwc2,g_serial
  - Save and close *cmdline.txt*
- Add or uncomment the following settings in the `/boot/config.txt` file:
```bash
enable_uart=0
dtoverlay=dwc2
```
- Save and close *config.txt*
- Create an empty file and call it *ssh* - no extensions, just *ssh*.
- Create another file called *wpa_supplicant.conf*, and open it:
  - Insert the following:
```bash
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
    ssid="<SSID>"
    psk="<passphrase/password>"
    key_mgmt=WPA-PSK
}
```
- Be sure to replace *\<SSID\>* with the SSID you want your pi to connect to, and replace *\<passphrase/password\>*
You are now done with this section, safely eject the SD card, and insert it into you *raspberry pi zero*.
###### First login:
- Power on the bridge, and give it about a minute to boot.
 - Using your favorite SSH client, login into your pi: `pi@<[hostname|IP Address]>`, where *hostname*, or *IP Address* are = to your Pi's.

**Note: Finding the IP address can be painful unless you have a utility on your PC or phone that can scan the network for active devices.  Recommend trying the default hostname *raspberrypi.local* first.**

###### Update OS:
```bash
sudo apt update && sudo apt full-upgrade -y
```
- Reboot your Pi when the upgrade is complete.
###### Additional OS Setup:
- Setup using raspi-config `sudo raspi-config`:
  - From the main menu, under *Advanced Options*.
    - select *Expand Filesystem* to expand.
  - From the main menu, under *System Options*.
    - Select *Hostname*, then change.
- REBOOt!
- Setup using raspi-config `sudo raspi-config`:
  - From the main menu, under *System Options*.
    - select *Boot / Autologin*, then select *Console Autologin*.
    - select *Password* and change.
    - select *Network at boot*, then select *No* to Disable *Waiting for network on boot*.
  - Select *localization Options*, and verify, or set:
    - Setup locals.
    - Set timezone on the pi.
    - Keyboard.
    - wifi location.
  - Select *Performance Options*:
    - Select *GPU Memory* and set *GPU memory* to 32MB.
  - Under the *Main Menu*, select *Finish*, and if you are asked to reboot, do so.
###### Install dependencies:
```bash
sudo apt install screen git minicom tio rfkill xterm ser2net -y
```
- Reboot your Pi when the dependacies have been installed
###### Pre-Requisites to software installation:
```bash
mkdir -p /home/pi/Projects/
```
###### Download and setup the serial to bluetooth scripts:
- In the Projects folder, initialize git, and clone the following repository:
```bash
cd $HOME/Projects/
git init
git clone https://github.com/lgbrownjr/ser2bt-bridge.git
```
- Run the upgrade tool:
```bash
cd ser2bt-bridge/
sudo ./upgrade basic
```
###### Bluetooth setup:
- Open `/etc/bluetooth/main.conf`

`sudo nano /etc/bluetooth/main.conf`
  - Uncomment and/or change the following settings:
    - `DiscoverableTimeout = 0`
    - `PairableTimeout = 0`
  - Save and close `/etc/bluetooth/main.conf`
- Restart the bluetooth service:
```bash
sudo systemctl restart bluetooth.service
```
- type in `sudo bluetoothctl`, and press enter.
  - You should see *Agent Registered*, then a prompt.
  - Type in `show`
  - You are looking for three items in the output:
    - Powered: yes
    - Discoverable: Yes
    - Pairable: Yes
  - If all three items match with what is on your screen, then type `exit` and skip over the rest of the bluetooth section.
  - Otherwise, type in the following:
```sh
power on
discoverable on
pairable on
```
  - Type in `show` to verify, then `exit` to leave bluetooth control and return to bash.
###### Additional Network Setup:
In order for your pi to keep the correct time, perform updates, or allow an alternate way to access the pi, it is advisable you add more networks into your *wpa_supplicant.conf*.  Examples include: allowable work networks, your home network, your hotspot, and even hotspots of your peer's phones (as allowed).
- Open `/etc/wpa_supplicant/wpa_supplicant.conf`, and add the following:
```bash
network={
    ssid="<SSID>"
    psk="<passphrase/password>"
    key_mgmt=WPA-PSK
}
```
- One block for each network you want to add.
 - Make sure to set the ssid and psk as needed.
 - **Be sure to test each network.**
###### We're Done!
If everything went as planned, your *raspberry pi zero w* should be acting like a bluetooth to serial bridge, allowing you to connect to a switches console port via bluetooth from your computer.
- Now, reboot your *raspberry pi zero w*.
- After the raspberry pi has rebooted, use your PC/laptop to pair with it.
- Look for a device advertising your pi's *hostname*
- The Pi should advertise that it supports serial communications, so you'll be able to associate it with your PC's com/ttyUSBx/ttyACMx ports.
  - Keep in mind, that no pin will be requested.  Your PC should just pair with the pi
  - Under Widows 10, after pairing, select *More Bluetooth Settings*, under *Related settings*, on the right side of the settings window.
- Once that's done, go ahead and open your favorite terminal program, and point it to the com/ttyUSBx/tty/ACMx port, and set it up to connect at 115200 bps, n/8/1, xterm.
### Full setup:
#### Installation of the *UPS* & *e-ink screen*:
The addition of am e-paper screen and ups backup will allow you to continue providing power to the Pi while not being plugged into a power source, and to easily tell the status of the bridge (Pi) without having to login to check.
#### Parts needed for this phase:
- For Battery UPS, we have two supported options:
  - The first option is a [ups-lite](https://www.ebay.com/itm/UPS-Lite-for-Raspberry-Pi-Zero-/352888138785).
  - The second UPS option is a PiSugar2 which also has a built-in real time clock, and a button that can be controlled via software, but at double the cost as the &ups_lite*.
- For status and system health updates, attach a [waveshare.2.13 e-paper](https://www.waveshare.com/2.13inch-e-Paper-HAT.htm) display.
#### Full Installation:
Coming soon:
## Known issues:
- With respect to full installation, I can't get the services to load in a manner where the e-paper screen does not wake up soon enough in the boot sequence and takes 20 seconds for the pi to completely to start the status screen.
  - Basic installation has not boot issues.
- For some reason, while connected via bluetooth, one cannot update the OS, or githib repositories.  A workaround, is to open a `screen` session, tehn perform any update taskes.  Another workaround would be to ssh into it as well...
## Improvements:
Features I want to add to this project:
- Add a session logging feature for sessions that are connected to a switch, or router. (Done).
- Build an installation script to automate most of the installation steps. (working on).
- add support for RTC (Real Time Clocks) so as not to have to rely on ntp so much, especially in envornments where there is no wifi available to the pi.
- Update the scripts to support USB micro to multiple serial ports to support connectivity to more than one switch at a time.
- I'm not sure if this even doable, but attempt to allow multiple concurrent bluetooth connections, especially if the item listed above is completed.
- Continue testing *Overlay FS* as a means to protect the SD cards from corruption.
- Make the ser2bt_status script run more effeciently - if possible.
Again, will be constantly updating the documentation, so check back for more.
#### How to use:
1. Power on the *bridge*:
   1. For the basic option, Plug the power into the *bridges* power port.  See 
   2. If your version of the *bridge* has a UPS, then slide the switch to the on position.
   3. To charge the UPS, insert the power cord into the UPS's power input plug, do not power the pi using the pi's power port.

![image](https://user-images.githubusercontent.com/15677301/109876709-13fc8700-7c40-11eb-8a3b-0795a1f350c1.png)

# ser2bt-bridge
---
## Serial to Bluetooth bridge for raspberry pi zero w
Before we begin, understand that everything in this repository is a work in progress...  :slightly_smiling_face:
### Definitions:
I tend to use several different discipters for each piece thats involved with this project, so I've tried to define them below to helpkeep the reader from being confused:
* For the purpose of this project, the terms *slave* refers to a end device you want to connect to, such as a router, switch, Firewall, Wireless LAN Controller, or any appliance that has a console interfiace.
* The terms *master*  refers to the PC, laptop, phone, or tablet.
* The terms *bridge*, or *pi* refer to the *raspberry pi zero w*, that is being used as a *bridge* to connect *master* to *slave*(s).
* The terms *user*, *you*, *network engineer*, *network administrator*, *administrator*, or *engineer* all refer to the person using this *bridge*.
### Preamble:
This project is made up of a set of scripts, services and libraries that allow a user to connect "through" a *raspberry pi zero w* from their phone/tablet/laptop's bluetooth interface, to the console port of a *slave* device such as a switch, router, firewall, etc.  This allows the network/system engineer to manage devices via it's console port, while enjoying the benefit of not having to be tethered right up to it.
#### How it works at a high level/Feature List:
These scripts and services basicaly utilize *screen* and *rfcomm* to "bridge" each connection between the *master*, and the *slave* you are attempting to connect to. 
* By design, this prject does not have security in mind, preferring instead to focus on easy discovery, pairing, and connectivity to allow the network administrator to focus on getting their work done.
  * The Bridge will always be discoverable, and will not require a pin to complete the pairing process.
  * This has been tested with *master* devices using the following Operating Systems: Linux, Android, Windows 10, and ChromeOS (with caveats).
  * When connecting to the bridge over bluetooth, the administrator will be auto logged-in as pi.
    * This will in no way affect access to the slave device. If the Slave requires a username/password to access it, you will still be required to use those credentials.
* Connection between the *master* and the bridge will be 9600 Baud - this is to maximize the possible range.
* Once the *master* is connected to the *bridge*, it will attempt to look for any available serial (usb or acm) ports.  At this point one of three things are expected to occur:
  * If the *bridge* was connected to a single *slave*, then it will open a *screen* session to that serial port outomagically.
  * If the *bridge* was connected (via OTG usb hub), then it will create one *screen* session for each serial port it found, list them on your display, and exit to shell.
  * If the *bridge* does not detect any new usb/acm ports, then it will state that fact and then drop to the *bridges* bash shell.
* The connection between the bidge and the *slave* is set to 9600 Baud.  I'm looking to set this as a configurable element in the future.
* While connected to a *slave*, the *bridge* will begin logging all session traffic between the *master* and *slave*. (This is why it is important to make sure the *bridge* somehow receives time from an external source, and/or onboard rtc.)
* If you become disconnected from the *bridge*, and want to reconnect, do not try to use the terminal program's *reconnect* feature.  Close the window, and then re-open the connection profile.
* If your setup has one of the two UPS's listed below, then services that will monitor battery level, and will automatically shutdown if the battery level reaches 2%.
  * If you are using the PiSugar2 UPS option, then you get several added benefits:
    * An on board RTC.
    * A button to safely turn off the *bridge* when you are done using it.  (This makes it so much easier then having to login just to power it off!)
* If your setup has a *waveshare* e-ink screen, then there are services that will monitor and display uptades as to the systems health/status.
* Telnet is installed and is used for bridging to serial connections via *ser2net*.
* If you are relying on the *slave's* USB port to supply power to your bridge, and decide to reboot the slave, your bridge will most likely be un-gracefully powercycled along with it.  This is not good as there is a risk that your pi's SD card will become corrupted, and stop working all-to-gether.  There are two possible ways around this:
  * Add a battery backup, to allow the pi to weather those pesky, but necessary.  This will allow the pi to be moved around between closets, or devices without powering it down, and back up.  See below for more details.
  * Turn on *Overlay FS*.  This basically, turns your pi's sd card into a read only drive, so the risk of corrupting your SD card goes way, way down.  The down side is that you need to turn *Overlay FS* Off to update it or to make configuration adjustments, then turn it back on.  I'm till testing this feature to see how well it works over the long run.

---
## Setup:
There are two different setup options, basic, and full.
* Basic should be used if you are only using a pi, and do not wish (at this point) to add a screen, or an external battery.
* Full should be used if you are using the pi, along with the e-ink display, and an external UPS.
### Basic setup:
The following steps will guide you through the process getting this system to work from just after everything is unboxed, to the point where you are connecting to a switch, router, or whatever - that is the raspberry pi zero, by itself acting as a bluetooth to serial bridge.  We will be using headless installation method, so you will not need a keyboard, mouse, or monitor.
#### Parts needed for Basic setup:
You will need:
* A *raspberry pi zero w* - at a minimum, but if you don't like soldering, and have at least a desire to expand, get the *raspberry pi zero wh* instead.
* An SD card with a minimum size of 8G.  Don't skimp hear, you'll need to get a quality card to weather any accidental power-cuts.  an good example is:  [Example](https://www.amazon.com/SanDisk-Extreme-MicroSDXC-Everything-Stromboli/dp/B087SNYQLJ?pd_rd_w=gwWVo&pf_rd_p=19ad5bd3-3223-4635-a9ad-e42b3305d40b&pf_rd_r=H004CN0Q32QCP6VHNET2&pd_rd_r=9e6d3d01-28b1-4ade-87f1-e02d15f8f8ae&pd_rd_wg=uCCau&pd_rd_i=B087SNYQLJ&psc=1&ref_=pd_bap_d_rp_10_t)
* A USB type A to RJ45 serial cable:  [Example](https://www.amazon.com/gp/product/B01AFNBC3K/ref=ppx_yo_dt_b_asin_title_o07_s00?ie=UTF8&psc=1)
* A USB micro to USB type A for power:  [Example](https://www.amazon.com/6in-Micro-USB-Cable-6-inches/dp/B003YKX6WM/ref=sr_1_18?dchild=1&keywords=usb+micro+to+usb+a+male+6+inch+uart+cable&qid=1599147190&s=electronics&sr=1-18)
* A USB micro to USB type A Female to connect to a USB type A to RJ45 serial cable to connect to a Cisco RJ45 console port:  [Example](https://www.amazon.com/UGREEN-Adapter-Samsung-Controller-Smartphone/dp/B00LN3LQKQ/ref=sr_1_2?dchild=1&keywords=usb%2Bmicro%2Bto%2Busb%2Ba%2Bfemale%2Bcable&qid=1599146495&s=electronics&sr=1-2&th=1).
* A Micro USB (Pi side) to Mini USB (switch side) to connect between the raspberry pi's usb port to the switches USB-console port:  [Example](https://www.amazon.com/gp/product/B018M8YNDG/ref=ox_sc_act_title_1?smid=ATVPDKIKX0DER&psc=1)
* Optional:  A Micro USB (pi side) to USB A female OTG Hub.  This will permit you to connect the *bridge* to multiple *slave* devices, so you won't have to keep walking back to switch the cable back and forth.  A good example is if you have VSS/Stack, or a FHRP pair:  [Example](https://www.amazon.com/gp/product/B01HYJLZH6/ref=ppx_yo_dt_b_asin_title_o01_s00?ie=UTF8&psc=1)
* A case to house the pi.  Check this [option](https://www.amazon.com/Flirc-Raspberry-Pi-Zero-Case/dp/B08837L144/ref=sr_1_11_sspa?dchild=1&keywords=raspberry+pi+zero+battery+hat&qid=1600716473&sr=8-11-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUE0V0NONk1LS0hLNEEmZW5jcnlwdGVkSWQ9QTA5ODgwMDExTzgzV1hIVUxSQVJEJmVuY3J5cHRlZEFkSWQ9QTAxMTk0NDQySzdKM0UwV1FESTdBJndpZGdldE5hbWU9c3BfbXRmJmFjdGlvbj1jbGlja1JlZGlyZWN0JmRvTm90TG9nQ2xpY2s9dHJ1ZQ==) out for a good example, slightly pricey, but in my opinion, worth the cost.  Down side is that it will not work well with the *raspberry pi wh*'s.
#### Installation:
##### OS installation and setup:
- insert the SD card into a different computer to perform the first few steps:
  - Download link is [here](https://www.raspberrypi.org/downloads/raspberry-pi-os/).
  - Follow Raspbian’s directions [here](https://www.raspberrypi.org/documentation/installation/installing-images/README.md).
- Eject and re-insert the SD card, and use your PC's file explorer to open the SD card - should be called *boot*.
  - Add the following to the end of the first line in the `/boot/cmdline.txt` file:
    - modules-load=dwc2,g_serial
  - Save and close *cmdline.txt*
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

---
**Note**

Finding the IP address can be painful unless you have a utility on your PC or phone that can scan the network for active devices.  Recommend trying the default hostname *raspberrypi.local* first.

---

###### Update OS:
```bash
sudo apt update && sudo apt full-upgrade -y
```
Reboot your Pi when the upgrade is complete.
###### Additional OS Setup:
###### Setup using raspi-config
* Enter `sudo raspi-config`:
* From the main menu, under *Advanced Options*.
  * select *Expand Filesystem* to expand.
* From the main menu, under *System Options*.
  * Select *Hostname*, then change to a name with **6 characters**.
###### REBOOT!
* Setup using raspi-config `sudo raspi-config`:
  * From the main menu, under *System Options*.
    * Select *Boot / Autologin*, then select *Console Autologin*.
    * Select *Password* and change.
    * Select *Network at boot*, then select *No* to Disable *Waiting for network on boot*.
###### Select *localization Options*, and verify, or set:
* Setup locals.
  * Set timezone on the pi.
  * Keyboard.
  * wifi location.
  * Select *Performance Options*:
  * Select *GPU Memory* and set *GPU memory* to 32MB.
###### Complete:
Under the *Main Menu*, select *Finish*, and if you are asked to reboot, do so.
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
  + The first option is a [ups-lite](https://www.ebay.com/itm/UPS-Lite-for-Raspberry-Pi-Zero-/352888138785).
  + The second UPS option is a PiSugar2 which also has a built-in real time clock, and a button that can be controlled via software, but at double the cost as the &ups_lite*.
- For status and system health updates, attach a [waveshare.2.13 e-paper](https://www.waveshare.com/2.13inch-e-Paper-HAT.htm) display.
#### Full Installation:
Coming soon!

---
## How to use:
![Raspberry Pi Zero usb port location and definition:](/readme_md_images/rpi0_diagram_port.png)
### Power on the *bridge*:
1. Different ways, depending on your setup:
  1. For the basic *bridge* option, Plug the power into the *bridges* power port.  See 
  2. If your version of the *bridge* has a UPS, then slide the switch to the on position.
  3. To charge the UPS, insert the power cord into the UPS's power input plug, do not power the pi using the pi's power port.
  4. It will take up to 30 seconds to boot to a point where a *master* can connect to it via bluetooth.

---
**NOTE**

If you are interested in accurate time, I advise you let it connect to an available hotspot, or wlan within range. See:
[Additional Network Setup](#additional-network-setup)

---
### First time connecting to your *bridge*:
#### Pairing:
1. The *Bridge* is set to allways be available to pair with it, so this step should go by fairly easily and painlessly:
   1. Open bluetooth settings and pair with the bridge - the name of the bridge should be the hostname you assigned it during the setup.  See [Additional OS Setup:](#Additional-OS-Setup).
   2. Assign com/tty ports to the *bridge* device.
Pairing should now be complete!

#### Setting up your Favourite Terminal application to connect to your *Bridge*:
1. In your favourite terminal program (screen/minicom/putty/securecrt/etc).
2. Ccreate a connection profile to connect to your bridge using serial, and assign the profile the com/tty port that was assigned during pairing.
3. Use N81, and 9600 baud.
4. use xterm as your terminal type.
5. Now save and test.
6. Repeat steps for all devices that you might think that will need to connect.
You should now all of your device terminal programs setup to easily connect to the *bridge* as needed.

#### Connecting to your *bridge*:
1. open your terminal program.
2. Click on and launch/open the connection profile you just built.
3. A terminal should open up, and you should see the banner appear, along with the results of your bridges attemtps to connect to the slave(s), and then either the login prompt of the slave, or a list of possible slaves you can conncect with.

#### How To:
1. If you were dropped off in the *bridg*'s bash shell, you have access to perform updates, play games, set the time, whatever, here are some ideas:
   1. Set the timezone (for those travelers)
      1. follow from here: [Setup Using raspi-config](#setup-using-raspi-config)
   2. Set the date and time (if you don't have an onboard rtc, or access to a network:
      1. `sudo date --set="4 MAR 2021 18:00:00"
   3. Update the ser2bt software:
      1. `screen`
      2. `cd /home/pi/Projects/ser2bt/`
      3. `git pull`
      4. `sudo ./upgrade [full|basic|screen|ups]`
      5. `exit` to exit out of acreen.
   4. Update the OS:
      1. `screen` Need to use screen to be able to access network resources, this is a workaround to an issue that prevents reliable network communications while an admin is logged in.
      2. `sudo apt update -y`
         1. If the result of the above command included `no updates available`, then skip to step 4.
      3. `sudo apt full-upgrade -y`
      4. `exit` to exit out of screen.
2. If your *bridge* is connected to a single *slave*:
   1. `ctrl` + `a`, then `d` to suspend you screen session.
   2. `ctrl` + `a`, then `\` to terminate your screen session. (you can always re-enter).
   3. If you want to enter a serial session, and you either terminated the session prior, or plugged a cable in after boot, then run `ser2bt_bridge`.
   3. To return to an existing session after it has been suspended, then type `screen -r`
3. If your *bridge* is connected to multiple *slaves*:
   1. If you are in the *slave* (read switch), and you want to get out to do something or enter another switch, and come back, then:
      1. `ctrl` + `a`, then `d ` to suspend you screen session allowing you to return later.
      2. `ctrl` + `a`, then `\` to terminate your screen session. (you can always re-enter). 
   2. To re-nter a session that has been suspended, type `screen -r Switch_x`.
   3. To enter a switch that has never been entered, or had its screen session terminated, type `screen Switch_x` where x = the connection number.
   4. To list the available switches that you can enter, type `screen -l`
4. To Reboot your bridge, type `sudo reboot`
5. If you're lost, and you need to reconnect to the *slave* were connected to, type `ser2bt_bridge` to relaunch the discovery script.  if that gives you an error, then reboot.
6. To shutdown your bridge, type `sudo poweroff`
7. To resize your terminal, suspend/exit and *screen* sessions, and type `resize`
8. When you are within a screen session, configuring, or administering a *slave*:
   1. Use the *PageUp* key to enter scrolback mode, then continue to use *PageUp*/*PageDown* or *Up*/*Down* arrows to move up and down your buffer.  Use the *Escape* key to exit, and go back to the normal mode.
---

## Improvements:
Features I want to add to this project:
- [X] Add a session logging feature for sessions that are connected to a switch, or router.
- [X] Build an installation script to automate most of the installation steps.
- [X] add support for RTC (Real Time Clocks) so as not to have to rely on ntp so much, especially in envornments where there is no wifi available to the pi.
- [X] Add support for USB micro to OTG HUB's to allow connectivity to more than one *slave* at a time.
- [ ] I'm not sure if this even doable, but attempt to allow multiple concurrent bluetooth connections, especially if the item listed above is completed.
- [ ] Continue testing *Overlay FS* as a means to protect the SD cards from corruption.
- [ ] Make the ser2bt_status script run more effeciently - if possible.
---

## Known issues:
- [ ] For some reason, while connected via bluetooth, one cannot update the OS, or githib repositories.  A workaround, is to open a `screen` session in the bridge, then perform any update taskes.  Another workaround would be to ssh into it instead of using bluetoothe.

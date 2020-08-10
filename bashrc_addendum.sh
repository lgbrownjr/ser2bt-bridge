#Add the following at the end to each user's .bashrc file on the pi:

#If this login comes in from a bluetooth over serial line (rfcomm), then execute the following:
if [ $(tty) = "/dev/rfcomm0" ] ; then
	resize > /dev/null 2>&1 #Resize the screen.
	source $HOME/bin/format.sh #Add this formatting script that allows the following line to get the pretty colors.
	printf "\n${nor}Launching ${blue}bluetooth${nor} to serial bridging utility...${end}\n" #notify the user that ser2bt_bridge is about to be launched
	$HOME/bin/ser2bt_bridge #Launch ser2bt_bridge.
fi

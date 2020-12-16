#BEGIN ser2b-bridge .bashrc add-in
#Add the following at the end to each user's .bashrc file on the pi:

#If this login comes in from a bluetooth over serial line (rfcomm), then execute the following:

#Main Variable & declorations
source /usr/local/lib/format.sh
declare -a cmds=(resize stty ser2bt_bridge)
app_count=0
installed_app_count=0
TMOUT=1800 #30 minutes

#Check if the incomming connection is from rfcomm
if [ $(tty) = "/dev/rfcomm0" ] ; then
	for cmd in ${cmds[@]} ; do
		let app_count++
		if command -v ${cmd} > /dev/null 2>&1 ; then
			let installed_app_count++
	     else
	     	printf "\n${red}${cmd}${nor} not found, please use: \"${yel}sudo apt install ${cmd}${nor}\"\n"
	     fi
	done
	if [[ ${app_count} != ${installed_app_count} ]]; then
		exit_status=3
		exit_status_reason="\n${bro}Dependancies need to be met.${nor}\nExiting to shell"
		exit ${exit_status} # Exit as dependancies need to be met.
	fi

#resize the screen, the export the inactivity timeout, then launch the ser2bt_bridge script:
	resize > /dev/null 2>&1 #Resize the screen.
	printf "\n${nor}Launching ${blu}bluetooth${nor} to serial bridging utility...${end}\n" #notify the user that ser2bt_bridge is about to be launched
#	readonly TMOUT
	export TMOUT #Exporting the inactivity autologout timeout.
	/usr/local/bin/ser2bt_bridge #Launch ser2bt_bridge.
fi
#END ser2b-bridge .bashrc add-in
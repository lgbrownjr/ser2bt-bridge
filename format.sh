#color defenitions:
bla=$'\e[00;30m'
gre=$'\e[01;30m'
drk_red=$'\e[00;31m'
red=$'\e[01;31m'
grn=$'\e[01;32m'
drk_grn=$'\e[00;32m'
yel=$'\e[01;33m'
bro=$'\e[00;33m'
drk_blu=$'\e[00;34m'
blu=$'\e[01;34m'
mag=$'\e[00;35m'
cyn=$'\e[00;36m'
whi=$'\e[01;37m'
drk_whi=$'\e[00;37m'
end=$'\e[0m'
nor=$'\e[01;37m'

#Other attributes:
space=" "
no_curs=$'\e[?25l'
curs=$'\e[?25h'

#############################################################################################
#Formatting Functions:
##Center text on screen, based on screen width.
#Requires 2 inputs: the first being the number of formatting changes within the string to be centered;
#And the second is the string itself:
#Usage:
#center (4, "${grn}Marry ${nor}Had a ${cyn}Little ${nor}Lamb")  Where the 4 is equal to the mumber of color changes withing the string.
function center () {
  local ctrl_count="${1}"
  local str="${2}"
  local color_cost=8 #Cost of the extra characters to drscribe what color to use for a particular word
  local last_col=$(tput -T xterm cols) #Describes width of the terminal at the point where this command was executed.
  let ctrl_cost=(${ctrl_count}*${color_cost}) #Computes the total cost of all of the formatting within  the string.
  let real_str_len=(${#str}+${ctrl_cost})
  str=$(printf "%*s\n" $(((${real_str_len}+${last_col})/2)) "${str}")
  echo "$str"
}

function spinner(){
	local pid=$1
	local delay=0.25
	local spinstr='|/-\'
	printf "${no_curs}"
	while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
		local temp=${spinstr#?}
		printf "${nor}(${cyn}%c${nor})" "$spinstr"
		local spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b"
	done
	printf "    \b\b\b${curs}"
}


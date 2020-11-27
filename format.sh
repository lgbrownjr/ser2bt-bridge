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

#Formatting dunctions:
function center (){
  local ctrl_count="${1}"
  local str="${2}"
  local color_cost=8
  local last_col=$(tput -T xterm cols)
  let ctrl_cost=(${ctrl_count}*${color_cost})
  let real_str_len=(${#str}+${ctrl_cost})
  str=$(printf "%*s\n" $(((${real_str_len}+${last_col})/2)) "${str}")

  echo "$str"
}

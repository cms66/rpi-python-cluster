# Bash variables
usrname=$(logname) # Script runs as root
usrpath="/home/$usrname"
declare -A arrconf=()
pinum=$(hostname | tr -cd '[:digit:].')
pimodel=$(cat /sys/firmware/devicetree/base/model | cut -d " " -f3- | tr -d "\0")
pirev=$(cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}' | sed 's/^1000//')
osarch=$(getconf LONG_BIT)
